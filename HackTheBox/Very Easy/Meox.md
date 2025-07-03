---------------
- Tags: #telnet #protocols #reconocimiento  #weakcredentials #misconfiguration
-----------------------

![[9048671485fb53276d1c6ed764e717cd.png]]

![[d7672e8485cf0c0d0b4355504461b909.png]]

## 🧠 Enumeración inicial y acceso a la máquina

Usaremos Telnet para conectarnos directamente como `root`.


```bash
telnet 10.129.206.106
```

![[535652168b1afd051cced807dbc04a58.png]]

Nos encontramos con una consola abierta sin necesidad de credenciales adicionales.

## 🏁 Captura de la flag de root

Una vez dentro, simplemente listamos el contenido del directorio home del usuario `root`:

![[f4cd2bedf329aed9b415fd343067c74b.png]]

Y como vemos, hacemos un "cat flag.txt" para ver la flag.

🎯 Flag encontrada:
`b40abfde23665f766f9c61ecba8a4c19`

## ✅ Conclusión final

- La máquina tenía el servicio Telnet expuesto.
    
- Accedimos sin necesidad de credenciales interactivas.
    
- Obtuvimos la flag directamente desde el archivo `flag.txt`.





