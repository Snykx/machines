---------
- Tags: #ftp #ssh #pcap #wireshark #linpeas
---------------

![](../img/f1560106c70cb8c5fa2875a330ac9ec6.png)

## 🔢 Datos de la máquina

- **Nombre**: Cap
    
- **IP**: `10.10.10.245`
    
- **Sistema Operativo**: Linux
    
- **Dificultad**: Easy
    
- **Modo**: Guided Mode


## 🔍 Enumeración inicial

Nos preguntan, cuantos puertos TCP están abiertos:

![](../img/9746611fb6f2a4137635edd9acd0bceb.png)

```bash
nmap -sS -sC --top-ports 1000 -Pn (IP)
```

📘 **Parámetros explicados**:

- `-sS`: TCP SYN Scan (modo sigiloso, rápido y eficaz)
    
- `-sC`: Usa los scripts por defecto de Nmap (equivale a `--script=default`)
    
- `--top-ports 1000`: Escanea los 1000 puertos más comunes
    
- `-Pn`: Omite detección de host (asume que el host está vivo)
    

🧠 Este escaneo es ideal para una enumeración inicial rápida en pruebas de penetración.


![](../img/e1ce67e4e8fcae16a6cf1eefc1109b4f.png)

📥 **Resultado**:

```bash
- 21/tcp - FTP
    
- 22/tcp - SSH
    
- 80/tcp - HTTP
```

🎯 Además, el puerto 80 presenta el título `Security _Dashboard_`, indicando un servicio web.


## 🔗 Servicio web (HTTP)

Navegamos a `http://10.10.10.245` y encontramos un **panel llamado Security Dashboard**. En el menú lateral aparece:

- Security Snapshot
    
- IP Config
    
- Network Status

![](../img/b4579a0b735909f7cf2c2d46dc68f70d.png)


![](../img/7a04d5cbaa28fb65e5fe29fe725b98c2.png)

Tras clicar a: "*security snapshot"* , el navegador nos redirige a:

```bash
/data/<id>
```

✅ Respuesta: `data`


## 🤔 Acceso a escaneos de otros usuarios

Desde `/data/0`, pudimos acceder a datos de otros usuarios.

![](../img/357531be73570dac9a50740636e7b0ae.png)

✅ **Task 3**: ¿Se puede acceder a otros escaneos? → Respuesta: `yes`


## 📃 Descarga y análisis del PCAP

Desde la URL `/data/0` descargamos unos cuantos `.pcap`. Los abrimos con **Wireshark**:



![](../img/b74ec2f7a635f2f7726788816926773a.png)

🔎 Filtros aplicados:

```bash
ftp
```

📂 Observamos tráfico FTP sin cifrar, donde se muestran:

- Usuario: `nathan`
    
- Contraseña: `Buck3tH4TF0RM!`

![](../img/1b71df30bc23f6d6c454eb0aa75c0a81.png)

![](../img/1fed521c6344e447ad2ae127b0e46241.png)

## 🛡️ Acceso por servicios

🔌 Probamos FTP:

![](../img/83fbb90879b6d1f71e26774304e1af22.png)

Login: `nathan` / `Buck3tH4TF0RM!` ❌ Acceso fallido (servidor FTP deniega sesión)

🔐 Probamos SSH:

![](../img/9885ab83605d6837406d7198e9c9fd21.png)

🚀 **¡Conexión exitosa!**

✅ **Task 6**: ¿Dónde funciona también la pass? → Respuesta: `ssh`

## 📂 Flag de usuario

Una vez dentro como `nathan`:

📦 Contenido:

![](../img/2c1a15328f586e251be4990b55e0ecf0.png)

🏆 Flag enviada con éxito.

## 🛡️ Escalada de privilegios

### 🪤 Usamos `linpeas`

Leyendo el tutorial:

![](../img/4d8527b6c42fd6cc5c59c832ed76f0c1.png)

Descargaremos el *linpeas.sh* y lo dejaremos en la carpeta "home"

```bash
https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS
```


Subimos `linpeas.sh` y lo ejecutamos:

```bash
./linpeas.sh
```


![](../img/ded52dfd62391bacd2f0e10396a52383.png)

![](../img/a547dc39684bf9bbc1130edaa8b61aed.png)

Leyendo el tutorial:

![](../img/1c035723e28aba9a9c3fe9922351ef15-1.png)

![](../img/d9e8fd46bf64701243f22802d4a937c3.png)

Buscamos binarios con **capabilities** especiales:

```bash
getcap -r / 2>/dev/null
```

Resultado:

```bash
/usr/bin/python3.8 = cap_setuid,cap_net_bind_service+eip
```

Esto es clave: `cap_setuid` permite ejecutar como UID 0 (root) sin necesidad del bit SUID.

📚 Referencia:

```bash
import os
os.setuid(0)
os.system("/bin/bash")
```

Y al ejecutarlo en `/usr/bin/python3.8`, conseguimos shell como root:

![](../img/1b01d422aca0316bd652ae33629ec7cb.png)

📡 Prompt cambia a `root@cap:~#`

✅ **Task 8**: Full path al binario vulnerable: `/usr/bin/python3.8`

## 🌟 Flag de root

Una vez como root , buscaremos la carpeta de root para encontrar la flag.

![](../img/64fb8eb9a4fa004202e3f766ac467d6f.png)

🏆 Flag root conseguida con éxito.

## 🌟 Conclusión

- Enumeración web ✅
    
- Análisis de PCAP con Wireshark ✅
    
- Credenciales encontradas ✅
    
- Acceso por SSH como `nathan` ✅
    
- Obtenida flag de usuario ✅
    
- Escalada a root via capabilities con Python ✅
    
- Obtenida flag de root ✅
    

🔹 Excelente ejercicio para entender:

- Lectura de PCAPs
    
- Credenciales en texto claro
    
- Enumeración de capabilities
    
- Uso de Python para obtener root