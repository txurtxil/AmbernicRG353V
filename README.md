# 📡 RESUMEN DEL PROYECTO: CyberDeck OS (RK3566)
**Proyecto:** CyberDeck OS para PowKiddy X55.
**Base del Sistema:** ROCKNIX (Linux embebido), reconvertido en estación de mando táctica.
**Objetivo:** Control total de hardware, redes y ciberseguridad mediante una terminal nativa (`foot`) y un ecosistema de **Inteligencia Artificial (IA)** con control remoto vía Telegram.

---

## 🛠️ FASE 1: Construcción y Compilación del Kernel
Para lograr un sistema base limpio, partimos del código fuente de ROCKNIX.

* **Clonado del Repositorio:**
    ```bash
    git clone [https://github.com/ROCKNIX/ROCKNIX.git](https://github.com/ROCKNIX/ROCKNIX.git)
    cd ROCKNIX
    ```
* **Compilación para el Target:**
    ```bash
    make image PROJECT=Rockchip DEVICE=RK3566 BOARD=powkiddy-x55
    ```

---

## 🛑 FASE 2: El "Secuestro" del Sistema (Bypass de UI)
* **Bypass de EmulationStation:** Deshabilitación del servicio gráfico para forzar el arranque en modo terminal.
* **Corrección de Pantalla:** Parche en `extlinux.conf` para mantener el framebuffer activo.
* **Terminal Foot:** Configuración de Wayland con soporte completo para UTF-8 inyectando diccionarios de idioma en `/storage/.config/locale/` para visualización correcta de menús `dialog`.

---

## 🌐 FASE 3: El Motor de Red Personalizado
* **Autonomía:** Bypass total de ConnMan usando un binario privado de `wpa_supplicant`.
* **Script de Control:** `cyber_wifi.sh` con base de datos de contraseñas (`wifi_db.txt`) y forzado de DNS/Rutas.

---

## 🐳 FASE 4: Infraestructura de Contenedores y Kali Linux
* **Núcleo Kali:** Imagen persistente `kali-cyberdeck:latest` con red host.
* **Persistencia Avanzada:** Inyección de herramientas (`nmap`, `bluez`, `python3`, `pip`) mediante `docker commit` tras cirugías en caliente.

---

## 🖥️ FASE 5: Interfaz Táctica (War Room y Tmux)
* **Main Menu:** Hub central con telemetría de hardware (Temp, Batería, IP).
* **Tmux War Room:** Multiplexor de terminal con paneles de monitorización de contenedores y terminal de comandos simultánea.

---

## 🖨️ FASE 6: Wardriving e Impresión Térmica
* **Escaneo Dual:** Wardriving Bluetooth (BLE/Classic) con volcados de logs.
* **Salida Física:** Soporte nativo para impresora **Datecs DPP-250** mediante `rfcomm` y comandos `ESC/POS` para imprimir reportes de auditoría y etiquetas de drones.

---

## 🚁 FASE 7: Comando y Control de Drones (UAS)
* **Registro Táctico:** Gestión de IDs AESA y formateo de etiquetas tácticas en tamaño doble para identificación física de aeronaves.

---

## ⚙️ FASE 8: Automatización y Camuflaje
* **Auto-Join Wi-Fi:** Demonio persistente con soporte para MAC Spoofing y sincronización horaria automática.

---

## 🧠 FASE 10: Integración de IA - Proyecto Sentinel (C2)
Se ha migrado e integrado la **Tríada Sentinel**, convirtiendo el dispositivo en un nodo de IA operativo vía Telegram.



* **Arquitectura de la Tríada:**
    * **Bridge Multimedia:** Gestión de torrents (torrents.py) y búsqueda automatizada.
    * **Bridge 3D:** Generación de modelos vía OpenSCAD para despliegue rápido.
    * **Bridge Redes:** Integración de comandos de Kali Linux ejecutados remotamente desde Telegram.
* **Cirugía de Contenedor:**
    * Inyección de Python 3 y dependencias (`telebot`, `requests`, `Groq API`).
    * **Bypass SSL:** Redirección a mirrors universitarios (RWTH Aachen) para saltar bloqueos de Cloudflare.
    * **Parche de Rutas:** Reemplazo masivo de rutas dinámicas (de `/app/` a `/storage/scripts/sentinel/`) para asegurar persistencia en la tarjeta SD.

---

## 🛡️ FASE 11: Estabilidad y Blindaje de Red
* **Wi-Fi Watchdog:** Script de vigilancia que monitoriza la conexión cada 60s. Si la IP se pierde o hay caída de DNS, reinicia el motor de red y desactiva el `power_save` de la antena.
* **Parche MTU 1400:** Forzado de tamaño de paquete MTU a 1400 tanto en el Host como en el contenedor Kali para estabilizar los Handshakes SSL con los servidores de Telegram.
* **Inyección PYTHONPATH:** Configuración dinámica del entorno Python para permitir la importación de módulos modulares sin colisiones de directorio.

---

## 📊 FASE 12: Gestión de IA y Caja Negra
Se ha implementado un nuevo submenú de IA en la interfaz física:
* **Control Total:** Botones para Iniciar, Detener y ver el Estado de los bots de la Tríada.
* **Caja Negra (Logs):** Visor de telemetría en tiempo real que muestra el `tail -f` de los logs de depuración de los bots dentro del contenedor de Kali.

---

## 📦 FASE 13: Respaldo y Distribución
* **Backup de Imagen:** Sistema de reducción de particiones para imágenes `< 2GB`.
* **Cifrado:** Empaquetado en `.7z` con cifrado de cabeceras para protección de API Keys y bases de datos Wi-Fi.

---

## 🤖 PROMPT MAESTRO (Para retomar el trabajo)
Copia y pega este bloque en una nueva sesión para que el asistente conozca el estado exacto del CyberDeck.

**INICIO DEL PROMPT**
> Asume el rol de Asistente de Ingeniería en la "War-Room". Nuestro proyecto es el "CyberDeck X55" (RK3566).
>
> **Estado de la Infraestructura:**
> * **Sistema:** ROCKNIX con bypass de UI y terminal `foot`.
> * **Red:** Motor Wi-Fi privado con **Watchdog persistente** y MTU configurado a 1400 para estabilidad SSL.
> * **Contenedor:** Kali Linux (`kali_core`) sellado con `docker commit`, incluyendo Python 3, `iproute2` y arsenal de ciberseguridad.
> * **IA Sentinel:** Tríada de bots de Telegram (Multimedia, 3D, Redes) operativa. Los bots cargan sus llaves desde `sentinel_keys.sh` e inyectan la carpeta `modulos` vía `PYTHONPATH`.
> * **Hardware:** Soporte activo para impresora térmica Datecs (Bluetooth SPP).
> * **Software de Control:** Menú `ai_menu.sh` con funciones de "Caja Negra" para monitorizar logs en vivo.
>
> **Logros recientes:** Corregido el error de importación de `torrents`, parcheado el direccionamiento `/app/` obsoleto y estabilizada la conexión SSL de los bots.
>
> **Objetivo Actual:** Mantener la estabilidad del enlace C2 y expandir las capacidades ofensivas del bot de Redes usando las herramientas nativas de Kali.
