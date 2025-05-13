
-----------------
- Tags: #protocols #SMB #Reconnaisance #anonymous 
------------------------

![[dbc8160891f7dd2a3aaedb2c1ae52f99.png]]

![[84087fb8821b7cb3b93a701eca04a902.png]]

En esta maquina, usaremos el protocolo #smb

En las tareas que nos encontramos, nos piden:

![[11d553d71208ec5d829c3e1d23cd1588.png]]

Para encontrar estas soluciones, hemos hecho un #nmap #-sV #ip

![[30be22490b48a3945fcbbc5cf0dffa9a.png]]

Viendo que tarda mucho tiempo, haremos un scan más rápido como:

```bash
nmap -p- --min-rate 5000 -T4 -n -Pn "IP"
```

![[42da3a896eacf3543396366ff7e57103.png]]

![[ef05583e40a0d17f7e0261ea027bdc75 1.png]]

Aquí vemos, que ha tardado 36 segundos y que nos encontramos con unos cuantos puertos abiertos con sus servicios.

El puerto que opera con el protocolo SMB es el 445, y el servicio es el "microsoft-ds"

Sabiendo el protocolo que es, entraremos al servicio con:

```bash
smbclient -L //10.129.129.87
```

![[d11e8e1028d349ca55e109a93b255ef0.png]]

Podemos entrar como "smbclient -L //IP"  y/o añadir "-N" al final. Esto servirá para que no nos pida la contraseña, cuando ya sabemos que (por ejemplo) no tiene.

En las preguntas de la máquina ya nos está dando una pista que es:

![[0d7f9d1fd64c3aaf80ff0dd44cd5c07d.png]]

Entonces, nos conectaremos al recurso de WorkShares:

```bash
smbclient //10.129.129.87/WorkShares -N
```

![[41debf9086274230bdee1794409f6b91.png]]

Como vemos en la captura, hacemos un ls para buscar archivos, y nos encontraremos 2 carpetas.

En una de las carpetas, encontramos el flag.txt, lo descargamos con "get" y desde nuestro directorio, lo abriremos para ver nuestra flag:

![[08bcd1d1cb26c684b7d18b529c974a51.png]]

