-----------------
- Tags: #protocols #SMB #Reconnaisance #anonymous 
------------------------

![](../img/dbc8160891f7dd2a3aaedb2c1ae52f99.png)

![](../img/84087fb8821b7cb3b93a701eca04a902.png)

En esta maquina, usaremos el protocolo #smb

En las tareas que nos encontramos, nos piden:

![](../img/11d553d71208ec5d829c3e1d23cd1588.png)

Iniciamos un escaneo básico para identificar puertos abiertos:

![](../img/30be22490b48a3945fcbbc5cf0dffa9a.png)

Esto nos revela que el puerto `445` está abierto y que el servicio asociado es `microsoft-ds`, típico de SMB.

En caso de que este escaneo sea muy lento, usamos una versión rápida:

```bash
nmap -p- --min-rate 5000 -T4 -n -Pn "IP"
```

![](../img/42da3a896eacf3543396366ff7e57103.png)

![](../img/ef05583e40a0d17f7e0261ea027bdc75%201.png)

Esto nos revela múltiples puertos abiertos. Sin embargo, el foco es el puerto `445`, donde corre SMB.

## 🔍 Enumeración de recursos SMB

Listamos los recursos compartidos con `smbclient`:

```bash
smbclient -L //10.129.129.87
```

![](../img/d11e8e1028d349ca55e109a93b255ef0.png)

Si queremos evitar que nos pida contraseña (cuando ya sabemos que no la hay), usamos `-N`:

```bash
smbclient -L //10.129.129.87 -N
```

En las preguntas de la máquina ya nos está dando una pista que es:

![](../img/0d7f9d1fd64c3aaf80ff0dd44cd5c07d.png)

Uno de los recursos es `WorkShares`, que aceptará conexión sin contraseña:

```bash
smbclient //10.129.129.87/WorkShares -N
```

![](../img/41debf9086274230bdee1794409f6b91.png)

## 📂 Búsqueda de la flag en el recurso compartido

Una vez dentro de `WorkShares`, listamos el contenido:

Accedemos a la carpeta `James.P`:

Encontramos un archivo `flag.txt`, lo descargamos con:

Finalmente, en nuestro sistema local, lo abrimos:

![](../img/08bcd1d1cb26c684b7d18b529c974a51.png)

📌 **Flag encontrada:**

## ✅ Conclusión final

- La máquina expone un recurso compartido SMB accesible sin autenticación.
    
- Desde ese recurso, navegamos hasta un archivo sensible (`flag.txt`) y lo descargamos.
    

🔐 **Lección aprendida:** Nunca se deben compartir recursos en red sin autenticar. Es un error habitual en entornos mal configurados.