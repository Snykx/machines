------------
- Tags:  #redis #vulnerabilidad #database #reconocimiento #anonymous 
- -------------

![](../img/e5fca813b87b162f43abd76cccd4ae06.png)

![](../img/05ff8bc27996f24896bbf9f3eb57b865.png)

## 🔎 Escaneo de puertos con Nmap

Comenzamos con un escaneo rápido de todos los puertos usando `nmap`:

```bash
nmap -p- --min-rate 5000 -T4 -n -Pn 10.129.222.25
```

![](../img/564db3b6a6b313319a792f0817c990f7.png)

🟢 **Puerto abierto encontrado:**

- `6379/tcp` → Servicio Redis

![](../img/06e220c47006444128a134d177799cd0.png)

Viendo que es un servicio redis, nos conectaremos directamente:

![](../img/363ef433319e5b6a1a9e6c0bb7936841.png)

```bash
redis-cli -h 10.129.222.25
```

## 🔗 Conexión al servicio Redis

Redis es una base de datos en memoria, y si no está configurado correctamente, permite conexión sin autenticación. Usamos `redis-cli`:

![](../img/48696d4fa58499f14132c7bc581c6e59.png)

![](../img/092fd578d90a7a44501efef0f338422e.png)

```bash
redis-cli -h 10.129.59.61
```

Una vez dentro, ejecutamos `info` para ver detalles del sistema y versión del servicio:

![](../img/a51ae9cf174d6f3ba02686eee6ed11b7.png)

![](../img/40e51a22dfc2046bfbbe128c4f3a9c77.png)

![](../img/53d42188cefdce60f8951c5338cf5352.png)

![](../img/a2314c8b2a9b7d64a1225843772ddd40.png)

📌 Observaciones clave:

- `redis_version: 5.0.7`
    
- Sistema operativo: `Linux x86_64`
    
- Modo: `standalone`
    
- Claves disponibles: 4 (`db0:keys=4`)

*Como vemos, hay 4 claves en la base de datos "0"

## 🗝️ Búsqueda de claves en la base de datos

Seleccionamos la base de datos 0 (por defecto):

![](../img/7d312fdb3e74329c3fa0ae6b6803221e%201.png)

```bash
select 0
```

Verificamos cuántas claves hay (4)

```bash
dbsize
```

![](../img/e08e2c6a34db872e0a97b5730eb63e50%201.png)

Listamos todas las claves:

```bash
keys *
```

![](../img/4ddd4f56d6495cc6885912855c47af11.png)

![](../img/ba1f749c057453674f3b6506e16e9c7f.png)

📂 Claves encontradas:

1. numb
    
2. stor
    
3. temp
    
4. flag ✅

## 🏁 Extracción de la flag

Como buscamos la clave `flag`, la extraemos así:

```bash
get flag
```

📌 **Flag obtenida:**

![](../img/3756a2dba6ff9b930b3da5b19599a20f.png)

## ✅ Conclusión final

- El servicio Redis expuesto sin autenticación es una vulnerabilidad grave.
    
- Gracias a esto, accedimos directamente y obtuvimos la flag almacenada como clave de Redis.
    
- Redis no debe exponerse sin credenciales, y mucho menos con datos sensibles en entornos accesibles.
    

🔐 **Lección aprendida:** Siempre restringir el acceso a servicios como Redis con autenticación y firewalls.


