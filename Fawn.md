
-----------
- Tags: #FTP #protocols #Reconnaisance #anonymous 
- --------------------

![](attachment/cfe496a9e7e72dc7754a6f99882983fc.png)

![](attachment/2d8ef3706761bf892b7925a175e5d49b.png)

Ya que es una máquina con #ftp nos conectaremos al servidor FTP:

```bash
ftp 10.129.37.151
```

![](attachment/9ecd643920d0f3fd4929e420a2ce5b09.png)

Al no tener una cuenta, nos conectaremos como #anonymous

![](attachment/40303d0cd18ae2050d51d4b4b3ee676a.png)

Haremos un ls para buscar archivos en el servidor, y encontraremos un .txt :

![](attachment/0b7d56d8a906ad4e49d665f8b28b2200.png)

Seguidamente, lo descargaremos con "get flag.txt"  y lo tendremos descargado en nuestro directorio (en este caso, en la VM)

![](attachment/4fe168ccbe4a182b24a19017811aa815.png)

Lo abriremos con cat y ahi tendremos la flag:

![](attachment/915a61b366464a5a5b273914fc09af4d.png)

