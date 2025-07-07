---

---

-------
- Tags: #CustomApplications #apache #Reconnaisance #WebSiteStructureDiscovery #DefaultCredentials 
---------

![](../img/3f72b958969a0a2548c325ab6b4676d9.png)

> 🧩 **Dificultad**: Very Easy (Linux)
> 🕸️ **Dirección IP**: `10.129.223.133` 
> 🧠 **Temas**: Apache, reconocimiento, credenciales por defecto, descubrimiento de estructura web

---

## ✅ **Task 1: ¿Cómo se llama también al "directory brute-forcing"?**

🔠 **Respuesta**: `dir busting`

💬 Esta técnica consiste en probar rutas de directorios y archivos comunes en un servidor web para descubrir páginas ocultas. Se suele usar con herramientas como Gobuster, dirb o ffuf.

📌 También conocida como **fuerza bruta de directorios** o **descubrimiento de rutas**.

![](../img/5a6799be7a2edfa79f8254a43fcc0bf8.png)


## ✅ **Task 2: ¿Qué parámetro usamos en Nmap para detectar versiones?**

🔠 **Respuesta**: `-sV`

💬 Este flag de Nmap activa la detección de versiones de servicios. Permite obtener información como el nombre del software, su versión y protocolo asociado.

📌 Ejemplo:

```bash
nmap -sV 10.129.223.133
```

![](../img/fecd147fd843ec4e29b74ede36ab796c.png)

## ✅ **Task 3: ¿Qué servicio indica Nmap en el puerto 80/tcp?**

🔠 **Respuesta**: `http`

💬 Nmap detecta un servicio HTTP corriendo en el puerto `80/tcp`, lo cual indica que hay un servidor web activo.

![](../img/c0f6a9dbf89177fea2e95f6cf8db8c42.png)


## ✅ **Task 4: ¿Qué nombre y versión del servidor detecta Nmap en el puerto 80/tcp?**

🔠 **Respuesta**: `nginx 1.14.2`

💬 El servidor web está utilizando **nginx versión 1.14.2**, una versión que puede tener vulnerabilidades si no está bien configurada.

📌 Esto se confirmó gracias al escaneo de Nmap con detección de versiones:

```bash
sudo nmap -sS -sV --top-ports 1000 10.129.223.133
```

![](../img/ad01c4e5dd89a0e7f06d82fce151840c.png)

![](../img/0d3da6c330e5242b591e15bae0303199.png)

## ✅ **Task 5: ¿Qué flag usamos en Gobuster para especificar un escaneo de directorios?**

🔠 **Respuesta**: `dir`

💬 Gobuster permite distintos tipos de escaneo. Para buscar directorios (dir busting), se debe usar el modo `dir`:

```bash
gobuster dir -u http://10.129.223.133 -w /ruta/wordlist.txt
```

![](../img/de0e7093c35faaaf383b92952cca8595.png)

## ✅ **Task 6: ¿Qué parámetro añadimos a Gobuster para buscar extensiones PHP?**

🔠 **Respuesta**: `-x php`

💬 Para buscar archivos con una extensión específica como `.php`, se utiliza el flag `-x` seguido de la extensión:

```bash
gobuster dir -u http://10.129.223.133 -w /usr/share/wordlists/dirb/common.txt -x php
```

![](../img/bebb215541d73213d231d0ee318b50fb.png)

📌 Esto ayuda a detectar archivos que no aparecerían en una búsqueda sin extensión.

## ✅ **Task 7: ¿Qué página encontramos durante el dir busting?**

🔠 **Respuesta**: `admin.php`

💬 Usando Gobuster con `-x php`, encontramos el archivo oculto `admin.php`, lo que indica una posible zona de administración accesible desde el navegador.

```bash
gobuster dir -u 10.129.223.133 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php
```

![](../img/b0cd1e1df7f6e960f464ca5ff601b05f.png)


![](../img/dbe5721735a49d0d25d3e573f6632a4c.png)

## ✅ **Task 8: ¿Qué código de estado HTTP devuelve la página descubierta?**

🔠 **Respuesta**: `200`

💬 El código `200 OK` indica que la página `admin.php` fue encontrada y está disponible públicamente, sin restricciones de acceso inmediatas.

📌 Esto puede revelar una entrada administrativa sin autenticación o con credenciales débiles por defecto.

![](../img/deb191bb2545c3c1e1a0d5249192e2f1.png)

## ✅ **Task 9: ¿Qué credenciales por defecto nos permiten entrar al panel?**

🔠 **Respuesta**: `admin:admin`

💬 Probamos credenciales por defecto y el acceso con `admin:admin` fue exitoso. Esto nos permite visualizar la flag en la consola de administración (`admin.php`).

![](../img/a62677620de20f804e03ea9392e72b08.png)

![](../img/43f4904f57acbd7d90643adae57d941c.png)

## ✅ **Conclusión**

- 🧭 El escaneo inicial con Nmap reveló un servidor nginx en el puerto 80.
    
- 🔍 Realizamos fuerza bruta de directorios con Gobuster, lo que nos permitió descubrir `admin.php`.
    
- 📄 La página `admin.php` devolvía código 200, por lo que estaba accesible sin protección alguna inicial.
    
- 🔑 Utilizamos credenciales por defecto (`admin:admin`), lo que nos otorgó acceso al panel de administración.
    
- 🏁 Dentro de dicho panel se encontraba la flag, indicando éxito en la explotación.
    

✅ **Lecciones clave**:

- Importancia del hardening de servicios públicos.
    
- Peligro de dejar credenciales por defecto en producción.
    
- Cómo combinar Nmap + Gobuster para reconocimiento y acceso inicial.

