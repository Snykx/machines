------------
- Tags: #CustomApplications #protocols #apache #FTP #Reconnaisance #WebSiteStructureDiscovery #cleartextcredentials #anonymous 
------------

![[0bf529d5c2576923739cbde171b41d77.png]]

![[fdc75929839964ff411ae292f49a76d7.png]]

🧠 Enumeración inicial y análisis de servicios

Comenzamos con un escaneo de puertos para identificar servicios:

```bash
nmap -sC -sV 10.129.151.214
```

![[0b1e772325dc510305f15469cd19b704.png]]

- Puerto 21: `vsftpd 3.0.3` (permite acceso anónimo)
    
- Puerto 80: `Apache httpd 2.4.41`


![[727fe1e72f438c7b6a5fa95fbda80512.png]]

![[70c3cdc7d8f73cd074bf6f388e530870.png]]


**`-sC`** activa los scripts por defecto de Nmap. Sirve para hacer una exploración más profunda con scripts NSE.

**`vsftpd 3.0.3`** es la versión que responde en el puerto 21. Detectada por Nmap con `-sV`.

**`Apache httpd 2.4.41`**  Es la versión del servidor web detectada al escanear con `nmap -sV`.

## 📁 Acceso por FTP anónimo

Nos conectamos al FTP usando:

```bash
ftp 10.129.151.214
```

Ingresamos con el usuario:

```bash
anonymous
```


![[e24e4fa4d79a6cfead53d9bf275d452c.png]]

![[e1265468c0b28a393b6f407272ba15ce.png]]

El nombre de usuario para login anónimo en FTP es literalmente `anonymous`.

![[adf5efe2ef55ac468e66bc35936e48ea.png]]

**Código `230`** del FTP significa que el acceso anónimo fue exitoso.

Una vez dentro, usamos el comando `ls` para listar los archivos, y luego `get` para descargar los archivos: `allowed.userlist` y `allowed.userlist.passwd

![[f1d1698f0fae90fdebb8a05c715bf3c8.png]]

```bash
get allowed.userlist
get allowed.userlist.passwd
```

![[04919f40abafac54c8515a8eab2b4bdf.png]]

## 🔐 Revisión de credenciales

Analizamos el contenido de los archivos descargados:

```bash
cat allowed.userlist
cat allowed.userlist.passwd
```

![[7e21f4fdb47bdab5814631f319ec15e5.png]]

Vemos lo siguiente:

- Usuario: `admin`
    
- Posibles contraseñas:
	- `root
    
    - `Supersecretpassword1`
        
    - `@BaASD&9032123sADS`
        
    - `rKXM59ESxesUFHAd`

![[3ece44639e93adbc4b59dbcf79c40ebb.png]]

En el archivo `allowed.userlist`, descargado vía FTP, uno de los nombres con privilegios es `admin`.

## 🌐 Enumeración Web y descubrimiento de archivos

Con `gobuster` podemos buscar archivos interesantes en la web:

```bash
gobuster dir -u http://10.129.151.214 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php
```

![[030477a321da6dfd919661074170f08d.png]]

![[873d57c3b1db76cfb8ebca12f53db632.png]]

**`-x`**  *Flag de Gobuster que especifica extensiones de archivo a buscar (ej: `.php`).*


Esto nos revela la existencia de un archivo PHP:

```bash
login.php
```

![[548092939b2172422166d2eada9d8746.png]]


## 🔓 Ataque de login por HTTP

Accedemos al sitio web desde el navegador:

```bash
http://10.129.151.214
```

Utilizamos el archivo `login.php` descubierto con **Gobuster** y probamos credenciales del listado.

Después de varios intentos, conseguimos acceso con:

- **Usuario:** `admin`
    
- **Contraseña:** `rKXM59ESxesUFHAd`

## 🏁 Captura de la flag

Una vez logueados correctamente, se nos muestra la flag:

![[2755560e33abd3b82084063da3f98d1a.png]]

📌 **Flag encontrada:**

```bash
c7110277ac44d78b6a9fff2232434d16
```

## ✅ Conclusión final

- Se permite acceso anónimo a un FTP con archivos sensibles.
    
- A través de la lista de usuarios y contraseñas, accedimos a un panel web.
    
- Se expuso información crítica mediante malas prácticas: contraseñas sin cifrar y visibles.
    

🔐 **Lección aprendida:** Jamás dejar archivos con credenciales accesibles por FTP ni permitir acceso anónimo en servicios expuestos a internet. Además, las contraseñas deben estar cifradas y bien gestionadas.