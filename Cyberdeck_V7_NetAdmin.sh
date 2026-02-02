#!/bin/bash

# --- 1. CONFIGURACIÓN VISUAL (NO TOCAR) ---
export TERM=linux
export NCURSES_NO_UTF8_ACS=1
export SDL_VIDEO_CENTERED=1
export SDL_VIDEO_KMSDRM_SCALING=0

# Directorio donde guardaremos los backups que traigas de otros PCs
BACKUP_DIR="/roms/backups"
mkdir -p "$BACKUP_DIR"

# --- 2. FUNCIONES DE SISTEMA ---

prepare_screen() {
    # Forzar resolución
    if command -v fbset >/dev/null 2>&1; then
        fbset -g 640 480 640 480 32 > /dev/null 2>&1
    fi
    clear >&2
}

get_input() {
    prompt="$1"
    prepare_screen
    osk "$prompt" | tail -n 1
}

# NUEVA FUNCIÓN: Ejecuta en terminal real (pantalla negra) para ver progreso
run_terminal() {
    cmd="$1"
    prepare_screen
    echo "------------------------------------------------"
    echo " EJECUTANDO TAREA EN TIEMPO REAL..."
    echo "------------------------------------------------"
    echo ""
    # Ejecutamos el comando y mostramos todo en pantalla
    eval "$cmd"
    echo ""
    echo "------------------------------------------------"
    echo " TAREA FINALIZADA."
    echo " Pulsa cualquier boton (o START) para volver."
    read -n 1 -s -r
}

show_result() {
    prepare_screen
    msgbox "$1"
}

# --- 3. SUBMENÚS ---

network_tools() {
    while true; do
        raw_choice=$(get_input "RED: 1-Ping 2-Speed 3-iperf 4-WiFi")
        if [ -z "$raw_choice" ]; then return; fi

        # Limpieza V6 (La que funcionó)
        clean_choice=$(echo "$raw_choice" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -cd '0-9')
        final_choice=${clean_choice: -1}

        case "$final_choice" in
            1) 
               host=$(get_input "Escribe Host (ej: google.com)")
               [ -z "$host" ] && continue
               host=$(echo "$host" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '[:cntrl:]')
               
               # AHORA USAMOS run_terminal PARA VERLO EN VIVO
               run_terminal "ping -c 5 $host" ;;
            2) 
               # Speedtest tarda, así que mejor ver que está vivo
               run_terminal "speedtest-cli --simple" ;;
            3) 
               # Instrucciones previas para iperf3
               prepare_screen
               msgbox "INSTRUCCIONES SERVIDOR:\n\nEn el otro PC, debes ejecutar:\n'iperf3 -s'\n\nPulsa OK cuando el otro PC este listo."
               
               server=$(get_input "IP del Servidor iperf3")
               [ -z "$server" ] && continue
               server=$(echo "$server" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
               
               run_terminal "iperf3 -c $server -t 5" ;;
            4) 
               run_terminal "iwlist wlan0 scan | grep -E 'ESSID|Signal'" ;;
            *) 
               show_result "Error. Opcion no valida." ;;
        esac
    done
}

# NUEVO MÓDULO: AUDITORÍA Y BACKUP
remote_admin() {
    # 1. Conexión
    raw_host=$(get_input "IP del Equipo Linux Remoto")
    [ -z "$raw_host" ] && return 
    host=$(echo "$raw_host" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '[:cntrl:]')

    raw_user=$(get_input "Usuario SSH Remoto")
    [ -z "$raw_user" ] && return
    user=$(echo "$raw_user" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '[:cntrl:]')

    raw_pass=$(get_input "Contraseña SSH")
    [ -z "$raw_pass" ] && return
    pass=$(echo "$raw_pass" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    
    msgbox "Conectando a $host..."
    
    if sshpass -p "$pass" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user"@"$host" "echo OK" 2>&1 | grep -q "OK"; then
        show_result "¡CONECTADO! Accediendo al sistema..."
    else
        show_result "Error al conectar. Verifica IP."
        return
    fi
    
    while true; do
        # Menú de administración
        raw_action=$(get_input "ADMIN: 1-Discos 2-Top 3-Backup 4-Salir")
        if [ -z "$raw_action" ]; then return; fi
        
        clean_action=$(echo "$raw_action" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -cd '0-9')
        final_action=${clean_action: -1}

        case "$final_action" in
            1) 
               # Análisis de disco remoto (df -h)
               run_terminal "sshpass -p '$pass' ssh $user@$host 'echo [DISCOS]; df -h; echo; echo [MEMORIA]; free -m'" ;;
            2) 
               # Procesos remotos
               run_terminal "sshpass -p '$pass' ssh $user@$host 'top -b -n1 | head -n 15'" ;;
            3) 
               # HERRAMIENTA DE BACKUP
               remote_path=$(get_input "Ruta remota a copiar (ej: /etc)")
               [ -z "$remote_path" ] && continue
               remote_path=$(echo "$remote_path" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
               
               msgbox "Se va a copiar:\n$host:$remote_path\n\nA tu tarjeta SD:\n$BACKUP_DIR\n\n(Esto puede tardar)"
               
               # Comando RSYNC (Copia inteligente)
               run_terminal "rsync -avz -e 'sshpass -p $pass ssh' $user@$host:$remote_path $BACKUP_DIR" 
               
               msgbox "Backup finalizado. Revisa /roms/backups" ;;
            4) return ;;
            *) show_result "Opcion invalida." ;;
        esac
    done
}

# --- 4. BUCLE PRINCIPAL ---
while true; do
    raw_main=$(get_input "MENU: 1-Red 2-RemoteAdmin 3-Salir")
    
    if [ -z "$raw_main" ]; then
        clear
        exit 0
    fi

    clean_main=$(echo "$raw_main" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -cd '0-9')
    final_main=${clean_main: -1}

    case "$final_main" in
        1) network_tools ;;
        2) remote_admin ;;
        3) clear; exit 0 ;;
        *) show_result "Error. Escribe 1, 2 o 3." ;;
    esac
done
