# 📡 RESUMEN DEL PROYECTO: CyberDeck OS
**Proyecto:** CyberDeck OS para PowKiddy X55 (Rockchip RK3566).
**Base del Sistema:** ROCKNIX (Distribución Linux embebida orientada al gaming, reconvertida en herramienta de ciberseguridad/terminal).
**Objetivo:** Eliminar la interfaz gráfica de juegos (EmulationStation), forzar un entorno de terminal nativo (`foot`) con menús interactivos (`dialog`), y lograr control total sobre el hardware de red, Bluetooth, contenedores Docker y despliegue táctico de forma autónoma.

---

## 🛠️ FASE 1: Construcción y Compilación del Kernel
Para lograr un sistema base limpio, partimos del código fuente de ROCKNIX.

* **Clonado del Repositorio:**
    ```bash
    git clone [https://github.com/ROCKNIX/ROCKNIX.git](https://github.com/ROCKNIX/ROCKNIX.git)
    cd ROCKNIX
    ```
* **Compilación para el Target (RK3566 / PowKiddy X55):**
    ```bash
    make image PROJECT=Rockchip DEVICE=RK3566 BOARD=powkiddy-x55
    ```
    *Nota: Esto genera un archivo `.img.gz` original de ROCKNIX. Se graba en la partición base de la tarjeta SD.*

---

## 🛑 FASE 2: El "Secuestro" del Sistema (Bypass de EmulationStation)
El núcleo táctico de este proyecto fue evitar que ROCKNIX lanzara su interfaz de juegos y, en su lugar, nos diera control directo de la terminal.

* **Deshabilitar EmulationStation:** Se modificó el sistema de arranque (Systemd/Autostart) para bloquear el servicio `emulationstation.service`.
* **Corrección de Pantalla Negra (`extlinux.conf`):** Al matar la UI gráfica, la pantalla del X55 se apagaba. Se parcheó la partición de arranque (BOOT) modificando el archivo `extlinux.conf` para mantener el *framebuffer* activo y evitar la suspensión del panel LCD.
* **Inyección de Terminal (`foot`):** Se configuró el perfil del usuario (a través de los scripts en `/storage/.config/profile.d/`) para que el sistema lance automáticamente el emulador de terminal Wayland `foot` a pantalla completa en el tty principal.
* **Solución del Bug UTF-8 (Locale):** `foot` se bloqueaba ("No such file or directory") por falta de diccionarios de idioma. Se inyectó la carpeta completa `.config/locale/` (conteniendo `en_US.UTF-8` y derivados) en la partición `/storage/`, dotando a la terminal de la codificación correcta para mostrar los bordes de `dialog` sin errores.

---

## 🌐 FASE 3: El Motor de Red Personalizado
ROCKNIX utiliza ConnMan, el cual genera conflictos y bloqueos de red al intentar usar redes complejas o inyectar IPs. Se diseñó un motor de red 100% autónomo.

**Componentes inyectados en `/storage/`:**
* **Binario Privado:** Se compiló/aisló el ejecutable `wpa_supplicant` en `/storage/scripts/bin/wpa_supplicant` para que el script no dependa de las actualizaciones del SO.
* **Script de Control (`cyber_wifi.sh`):**
    * Interfaz UI gráfica en consola usando `dialog`.
    * Base de datos de contraseñas guardadas en `/storage/.config/wifi_db.txt`.
    * Rutina de Conexión Forzada: Detiene ConnMan, arranca el motor privado, realiza el handshake WPA-PSK, solicita IP vía `udhcpc` y fuerza las rutas y el DNS de Google (`8.8.8.8`) directamente en el kernel.
    * Módulo integrado para Activar/Desactivar servidor SSH como servicio persistente.

---

## 🐳 FASE 4: Infraestructura de Contenedores y Kali Linux
Para mantener el sistema base ROCKNIX inalterado y ligero, se desplegó Docker para contenerizar las herramientas ofensivas.


* **Motor Docker:** Instalado y ejecutado desde `/storage/scripts/docker/bin/docker`.
* **Núcleo Kali (`kali_core`):** Se implementó una imagen persistente (`kali-cyberdeck:latest`) ejecutándose en segundo plano (`sleep infinity`) con red host.
* **Persistencia:** Se inyectaron dependencias clave (`nmap`, `mc`, `htop`, `bluez`, `procps`) directamente en el contenedor mediante `docker commit` para evitar descargas en cada reinicio.

---

## 🖥️ FASE 5: Interfaz Táctica (War Room y Tmux)
Se desarrolló un sistema operativo por menús centralizado en `/storage/main_menu.sh` y un multiplexor de terminal avanzado.


* **Main Menu:** Hub central que muestra telemetría en tiempo real (IP, Batería, Temperatura, Reloj ajustado a `Europe/Madrid`) y redirige a los distintos módulos.
* **War Room (`start_war_room.sh`):** Interfaz dividida con `tmux`. 
    * *Tab 0 (Admin):* Split horizontal (30% Monitorización Docker Stats arriba, 70% Terminal de comandos abajo).
    * *Tab 1 (Monitor):* `htop` nativo de Kali a pantalla completa.
    * *Tab 2 (Explorador):* `mc` (Midnight Commander) a pantalla completa.
* **Atajos de Teclado (`.aliases`):** Inyección de atajos militares (`c` para clear, `k` para entrar a Kali, `s` para apagado rápido) persistentes tanto en la consola física como a través de conexiones remotas SSH.

---

## 🖨️ FASE 6: Operaciones de Red, Wardriving e Impresión Térmica
El módulo ofensivo (`kali_net_menu.sh`) proporciona herramientas de escaneo y salida física automatizada.


* **Vectores de Ataque:** Nmap automatizado (Ping Sweep, Aggressive, Stealth) apuntando a una IP o rango predeterminado (`192.168.1.0/24`). Logs guardados de forma segura.
* **Impresión Térmica Bluetooth (Datecs DPP-250):** * Rutinas de formateo `ESC/POS` nativas (títulos centrados, negritas, auto-corte de papel).
    * Enlace robusto por `rfcomm` con protección anti-cuelgues (reinicio forzado del demonio `bluetoothd -C` en modo SPP, inyección de `modprobe` y *timeouts* de seguridad).
    * Memoria dinámica: El sistema recuerda la MAC de la última impresora usada.
* **Wardriving Aéreo:** Escáner dual simultáneo (Bluetooth Clásico y Low Energy) de 30 segundos para capturar dispositivos del entorno y volcarlos a un log táctico.

---

## 🚁 FASE 7: Comando y Control de Drones (UAS)
Módulo dedicado (`drones_menu.sh`) para operaciones aéreas.
* **Registro AESA:** Base de datos local para guardar IDs de Operador de Drones (pre-cargado con el formato `ESP`).
* **Etiquetado Táctico:** Inyección de comandos HEX `ESC/POS` para imprimir la identificación del operador en texto de tamaño doble (x2 Ancho/Alto) ideal para el chasis de los UAVs.

---

## ⚙️ FASE 8: Automatización, Auto-Join y Camuflaje

El dispositivo opera de forma autónoma sin necesidad de interacción manual tras el arranque.

* **Auto-Join Wi-Fi (`wifi_autojoin.sh`):** Demonio silencioso que arranca junto al sistema. Lee las redes guardadas, se conecta a la mejor opción, fuerza el gateway, inyecta la zona horaria (`TZ="CET-1CEST,M3.5.0,M10.5.0/3"`) y evita el bloqueo del usuario mediante sistemas de *lock-file* (`/tmp/wifi_boot_done`).
* **MAC Spoofing:** Opción integrada en el menú `SETTINGS` para aleatorizar la dirección MAC física de la antena Wi-Fi y prevenir rastreos.
* **Mantenimiento Profundo:** Rutinas de purga automática para limpiar contenedores y logs antiguos (Docker Prune y Purga de Logs de Kali/Drones).

---

## 📦 FASE 9: Extracción y Respaldo Genérico (< 2GB)
Para crear una imagen de distribución universal (que quepa en SDs de cualquier capacidad), se redujo el sistema de archivos saltando el espacio en blanco.

**Protocolo de Reducción:**
1.  Verificación: `sudo e2fsck -fy /dev/sdc2`
2.  Captura hasta el último sector ocupado:
    `sudo dd if=/dev/sdc bs=512 count=4292608 status=progress | gzip > cyberdeck_x55_generico.tgz`
3.  **Cifrado Militar (7-Zip):** Se protegió el archivo `.tgz` ocultando las cabeceras:
    `7z a -p'TU_CLAVE' -mhe=on cyberdeck_backup_CIFRADO.7z cyberdeck_x55_generico.tgz`

**Protocolo de Restauración y Auto-Expansión:**
* Para grabar: `gunzip -c cyberdeck_x55_generico.tgz | sudo dd of=/dev/sdc bs=4M status=progress conv=fsync`
* Auto-Resize: Para que la partición `/storage` se expanda al 100% de la SD en el primer arranque, se inyecta el archivo trigger: `touch /storage/.please_resize_me`
* Clonado en memoria interna (eMMC): `gunzip -c /storage/imgX55.tgz | dd of=/dev/mmcblk0 bs=4M conv=fsync`

---

## 🤖 PROMPT MAESTRO (Para iniciar un nuevo chat de IA)
Copia y pega el siguiente bloque exacto en tu nueva sesión para que el asistente asuma el rol, conozca todo el hardware, el estado actual y retome el trabajo.

**INICIO DEL PROMPT**
> Asume el rol de Asistente de Ingeniería de Sistemas y Ciberseguridad en la "War-Room". Nuestro proyecto es un "CyberDeck" construido sobre una consola portátil PowKiddy X55 (arquitectura Rockchip RK3566).
>
> **Contexto del Proyecto y Logros hasta ahora:**
> * **Sistema Base:** Clon compilado de ROCKNIX (Linux embebido). Anulada interfaz gráfica `emulationstation`. Terminal `foot` (Wayland) parcheada con locales UTF-8 en `/storage/.config/locale/`.
> * **Red y Automatización:** Motor Wi-Fi autónomo (`cyber_wifi.sh` y demonio de arranque `wifi_autojoin.sh`) que bypassa ConnMan, usa `wpa_supplicant` nativo, fuerza IP/DNS y ajusta el reloj a la zona horaria de España. Servidor SSH activo. Soporte para MAC Spoofing.
> * **Contenedores e IA:** Motor Docker ejecutando Kali Linux persistente (`kali_core`) con herramientas inyectadas (`nmap`, `bluez`, `mc`, `htop`).
> * **Menús y UI:** Sistema operativo central por `dialog` (`main_menu.sh`). Interfaz "War Room" dividida con `tmux` (Docker stats, consola con atajos `.aliases`, Htop, MC).
> * **Hardware Externo:** Control absoluto del Bluetooth para Wardriving y envíos nativos por puerto serie virtual (`rfcomm`, `ESC/POS`) a una impresora térmica Datecs DPP-250 para imprimir logs de Nmap y etiquetas de drones (tamaño doble). Rutinas blindadas contra cuelgues del puerto serie.
> * **Almacenamiento:** Todo alojado en `/storage` (ext4) con mecanismo `.please_resize_me`. Respaldo `.tgz` genérico cifrado.
>
> **Estado Actual:**
> El sistema es un CyberDeck autónomo: arranca, conecta a red, blinda su reloj, establece alias de teclado e inicia Docker en silencio. Módulos de red, drones e impresión funcionan al 100%. Estamos listos para integrar el Módulo de Inteligencia Artificial (API Groq/LLMs).
