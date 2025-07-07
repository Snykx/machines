
-------
- Tags: #progamming #rdp #Reconnaisance #weakcredentials 
-------

![](../img/53cd56d8e3ccd92f2bfbe649890ebced.png)

🧩 **Dificultad**: Very Easy (Windows)  
🕸️ **Dirección IP**: `10.129.188.65`  
🧠 **Temas**: RDP, credenciales débiles, reconocimiento

## ✅ **Task ***1: ¿Qué significa** ****_**RDP?**

*🔠 ****Resp****************ue****************sta****: *`Remote Desktop Protocol`

💬 RDP es un protocolo de Microsoft que permite a los usuarios conectarse de forma remota a otro sistema a través de una interfaz gráfica. Se usa comúnmente para administración r_em_ota.

📌 Común en servicios Windows escuchando en el puerto* `****3389****`.*

![](../img/8948acadfc03b3e333ebe1ff2eb0383c.png)

## ✅ **Task 2: ¿Qué acrónimo de 3 letras se refiere a la interacción con el host mediante línea de comandos?**

🔠 **Respuesta**: `CLI`

💬 CLI significa **Command Line Interface**. Es una forma de interactuar con un sistema a través de comandos escritos, sin entorno gráfico. Se usa ampliamente en administración y explotación de sistemas.

📌 Ejemplos de CLI: `cmd.exe`, `PowerShell`, `bash`, `sh`.

![](../img/44038529611f5901dd8e89e77121461f.png)

## ✅ **Task 3: ¿Y para interacciones con interfaz gráfica?**

🔠 **Respuesta**: `GUI`

💬 GUI significa **Graphical User Interface**. Es una interfaz visual que permite interactuar con el sistema a través de ventanas, botones, iconos, etc., sin necesidad de escribir comandos.

📌 Muy común en entornos Windows y Linux con escritorios como GNOME, KDE o XFCE.

![](../img/1872d04214f295934fafe61f673061fd.png)

## ✅ **Task 4: ¿Cuál es el nombre de una herramienta de acceso remoto antigua que no usaba cifrado y escuchaba por el puerto TCP 23?**

🔠 **Respuesta**: `telnet`

💬 Telnet es un protocolo antiguo de acceso remoto que permite conectarse a otros sistemas a través de una línea de comandos. No cifra el tráfico, por lo que las credenciales pueden ser interceptadas fácilmente.

⚠️ Debido a su falta de seguridad, ha sido reemplazado por SSH en la mayoría de los sistemas modernos.

📌 Escucha en el puerto `23` por defecto.

![](../img/d7120cc3ae18182656dbdde7a699b686.png)

## ✅ **Task 5: ¿Qué servicio se encuentra en el puerto TCP 3389?**

🔠 **Respuesta**: `ms-wbt-server`

💬 Este nombre identifica el servicio que ofrece Microsoft para conexiones de escritorio remoto, concretamente **Microsoft Remote Desktop Services**. Es el backend del protocolo RDP.

🔍 Se puede confirmar usando Nmap:

```bash
nmap -sS --top-ports 1000 10.129.188.65
```

📌 Resultado:

```bash
3389/tcp open  ms-wbt-server
```

![](../img/33da4cd5ad045079553d100cf1bd7e9f.png)

![](../img/44525863398a935eda8d8b9b4ba8c20a.png)

## ✅ **Task 6: ¿Qué opción se usa en** `**xfreerdp**` **para especificar la IP del host objetivo?**

🔠 **Respuesta**: `/v:`

💬 El parámetro `/v:` se utiliza en `xfreerdp` para indicar el host remoto (por IP o nombre de dominio) al que conectarse mediante RDP.

📌 Ejemplo:

```bash
xfreerdp /v:10.129.188.65
```

![](../img/d51c59c55d2f18aefc74f724214d825d.png)


💡 También se pueden añadir otras opciones como `/u:usuario` para indicar usuario, o `/p:contraseña` para facilitar autenticación.

### 🧩 Notas técnicas adicionales sobre `xfreerdp`

❌ Si al intentar ejecutar `xfreerdp` aparece:

![](../img/a917e99e77dd699203ef8e8f61aaefa4.png)

🔧 Es necesario instalarlo, pero **el nombre correcto del paquete** no es `xfreerdp`, sino:

```bash
sudo apt install freerdp2-x11
```

![](../img/98dbb87f6850ea740de8b2012b2cafec.png)

Esto instalará correctamente la herramienta en sistemas Debian/Ubuntu (como Kali, Parrot, etc.).

🛠️ `xfreerdp` forma parte del proyecto FreeRDP, un cliente RDP moderno y compatible con muchas opciones avanzadas.

💡 A veces es útil para pentesting porque permite iniciar sesión en escritorios remotos Windows directamente desde Linux.

![](../img/0a434190c2b16a9bb976129c58e0f6ca.png)

## ✅ **Task 7: ¿Qué nombre de usuario devuelve proyección de escritorio sin contraseña?**

🔠 **Respuesta**: `Administrator`

💬 Al usar el comando `xfreerdp /v:10.129.188.65 /u:Administrator` con contraseña en blanco, se logra conectarse correctamente al escritorio remoto. Este usuario representa el nivel más alto de privilegios en un sistema Windows.

```bash
xfreerdp /v:10.129.188.65:3389 /u:Administrator
```

![](../img/6093e2926dee4089eca466e0dc0b4b68.png)

![](../img/27904db4dc6c594347fb1495450c4fba.png)

📌 Verifica el certificado autofirmado, acepta con `yes` si aparece el mensaje de advertencia. Si no se indica el usuario con `/u:`, el nombre por defecto será el del sistema local (en este caso `alex`).

![](../img/044d44c2a7a32a9e1225f11af8535a16.png)

Encontraremos la flag en la primera y unica carpeta del sistema.

## 🧩 Conclusión final y análisis

✅ El sistema Windows objetivo permitía conexión remota RDP en el puerto `3389`, expuesto a Internet y **sin medidas de seguridad básicas**:

- Se detectó el servicio con Nmap (`ms-wbt-server`).
    
- Se accedió con la cuenta `Administrator` **sin contraseña**, lo cual supone una vulnerabilidad crítica.
    
- La interfaz gráfica se abrió correctamente usando `xfreerdp`, lo que otorga control total del sistema.
    

🛑 **Riesgos detectados:**

- Falta de autenticación en cuenta de administrador
    
- Certificado autofirmado sin confianza
    
- RDP expuesto al exterior sin firewall restrictivo
    

📌 Esta máquina es un excelente ejemplo de por qué las configuraciones por defecto en servicios RDP deben revisarse a fondo y protegerse con políticas seguras.

