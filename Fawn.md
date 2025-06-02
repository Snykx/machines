-----------
- Tags: #FTP #protocols #reconocimiento  #anonymous 
- --------------------

![](img/cfe496a9e7e72dc7754a6f99882983fc.png)

![](img/2d8ef3706761bf892b7925a175e5d49b.png)

Como se trata de una máquina #FTP, probamos acceso anónimo:

```bash
ftp 10.129.37.151
```

![](img/9ecd643920d0f3fd4929e420a2ce5b09.png)

Nos conectamos como `anonymous` (sin contraseña real). El sistema permite el acceso con permisos limitados.

![](img/40303d0cd18ae2050d51d4b4b3ee676a.png)

## 📁 Descarga de archivos y búsqueda de la flag

Una vez dentro del entorno FTP, listamos el contenido:

```bash
ls
```

Vemos que hay un archivo `flag.txt`, lo que sugiere que contiene la flag.

Descargamos el archivo:

```bash
get flag.txt
```


![](img/0b7d56d8a906ad4e49d665f8b28b2200.png)

Ya descargado en nuestro directorio (en este caso, en la VM)

![](img/4fe168ccbe4a182b24a19017811aa815.png)

Después, ya en nuestro sistema local, lo leemos con:

```bash
cat flag.txt
```

📌 **Flag encontrada:**

![](img/915a61b366464a5a5b273914fc09af4d.png)

## ✅ Conclusión final

- La máquina expone un servicio FTP sin autenticación, lo cual es una grave falla de seguridad.
    
- Mediante acceso anónimo, pudimos listar y descargar archivos desde el servidor.
    
- Encontramos la flag dentro de `flag.txt`, disponible en texto plano sin protección.