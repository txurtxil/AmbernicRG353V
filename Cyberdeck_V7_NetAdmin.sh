#!/bin/bash

# =================================================================
#  CYBERDECK V14 - GOLDEN MASTER
# =================================================================

# --- 1. CONFIGURACIÓN VISUAL ---
export TERM=linux
export NCURSES_NO_UTF8_ACS=1
export SDL_VIDEO_CENTERED=1
export SDL_VIDEO_KMSDRM_SCALING=0
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

# Directorio de backups
BACKUP_DIR="/roms/backups"
mkdir -p "$BACKUP_DIR"

# --- 2. FUNCIONES DE SISTEMA ---

force_resolution() {
    stty sane 2>/dev/null
    if command -v fbset >/dev/null 2>&1; then
        fbset -g 640 480 640 480 32 > /dev/null 2>&1
        fbset -a -g 640 480 640 480 32 > /dev/null 2>&1
    fi
    clear >&2
}

get_input() {
    prompt="$1"
    force_resolution
    osk "$prompt" | tail -n 1
}

run_tui() {
    cmd="$1"
    force_resolution
    eval "$cmd"
    force_resolution
}

run_terminal() {
    cmd="$1"
    force_resolution
    echo ">> EJECUTANDO: $cmd"
    echo "------------------------------------------------"
    eval "$cmd"
    echo "------------------------------------------------"
    echo " [PULSA 'A' o 'START' PARA VOLVER]"
    read -r
    force_resolution
}

show_msg() {
    force_resolution
    msgbox "$1"
}

clean_input() {
    echo "$1" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -cd '0-9'
}

# --- 3. SUBMENÚS ---

menu_network() {
    while true; do
        raw=$(get_input "RED: 1-Ping 2-Wavemon 3-Speed 4-iperf 5-Atras")
        [ -z "$raw" ] && return
        sel=$(clean_input "$raw"); sel=${sel: -1}

        case "$sel" in
            1) 
               host=$(get_input "Host:")
               [ -z "$host" ] && continue
               host=$(echo "$host" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '[:cntrl:]')
               run_terminal "ping -c 5 $host" ;;
            2) 
               if command -v wavemon >/dev/null; then
                   run_tui "wavemon"
               else
                   show_msg "Falta 'wavemon'."
               fi ;;
            3) run_terminal "speedtest-cli --simple" ;;
            4) 
               srv=$(get_input "IP Servidor:")
               [ -z "$srv" ] && continue
               run_terminal "iperf3 -c $srv -t 5" ;;
            5) return ;;
            *) ;;
        esac
    done
}

menu_system() {
    while true; do
        raw=$(get_input "1-Htop 2-MC 3-Shell 4-Disk 5-Mtrx 6-Info")
        [ -z "$raw" ] && return
        sel=$(clean_input "$raw"); sel=${sel: -1}

        case "$sel" in
            1) run_tui "htop" ;;
            2) 
               if command -v mc >/dev/null; then
                   run_tui "mc"
               else
                   show_msg "Falta 'mc'."
               fi ;;
            3) 
               while true; do
                   cmd_raw=$(get_input "SHELL > Comando (exit para salir):")
                   cmd=$(echo "$cmd_raw" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
                   if [ -z "$cmd" ] || [ "$cmd" == "exit" ]; then break; fi
                   run_terminal "$cmd"
               done
               ;;
            4) 
               if command -v ncdu >/dev/null; then
                   run_tui "ncdu /"
               else
                   run_terminal "df -h"
               fi ;;
            5) 
               if command -v cmatrix >/dev/null; then
                   run_tui "cmatrix -b -s"
               else
                   show_msg "Falta 'cmatrix'."
               fi ;;
            6) run_terminal "neofetch" ;;
            *) ;;
        esac
    done
}

menu_admin() {
    rh=$(get_input "IP Remota:")
    [ -z "$rh" ] && return
    rh=$(echo "$rh" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '[:cntrl:]')

    ru=$(get_input "Usuario SSH:")
    [ -z "$ru" ] && return
    ru=$(echo "$ru" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '[:cntrl:]')

    rp=$(get_input "Password:")
    [ -z "$rp" ] && return
    rp=$(echo "$rp" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

    force_resolution
    msgbox "Conectando..."
    if ! sshpass -p "$rp" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=4 "$ru"@"$rh" "echo OK" 2>&1 | grep -q "OK"; then
        show_msg "Error de Conexion."
        return
    fi

    while true; do
        raw=$(get_input "ADMIN: 1-Htop 2-Backup 3-Shell 4-Atras")
        [ -z "$raw" ] && return
        sel=$(clean_input "$raw"); sel=${sel: -1}

        case "$sel" in
            1) run_tui "sshpass -p '$rp' ssh -t $ru@$rh 'htop'" ;;
            2) 
               rpath=$(get_input "Ruta a copiar:")
               [ -z "$rpath" ] && continue
               rpath=$(echo "$rpath" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
               run_terminal "rsync -avzP -e 'sshpass -p $rp ssh' $ru@$rh:$rpath $BACKUP_DIR" ;;
            3) run_tui "sshpass -p '$rp' ssh $ru@$rh" ;;
            4) return ;;
        esac
    done
}

# --- FUNCIÓN OPTIMIZADA: LANZAMIENTO DIRECTO ---
launch_games() {
    force_resolution
    echo "Cargando EmulationStation..."
    
    # RUTA CONFIRMADA POR EL USUARIO (PRIORIDAD ABSOLUTA)
    GAME_BIN="/usr/bin/emulationstation/emulationstation"
    
    if [ -f "$GAME_BIN" ]; then
        "$GAME_BIN"
    else
        # Fallback de emergencia por si cambia en el futuro
        echo "Ruta principal falló. Buscando alternativa..."
        ALT_BIN=$(find /usr /opt -name "emulationstation" -type f -executable 2>/dev/null | head -n 1)
        if [ -n "$ALT_BIN" ]; then
            "$ALT_BIN"
        else
            echo "ERROR: No se encuentra EmulationStation."
            read -r
        fi
    fi
    
    force_resolution
}

# --- BUCLE PRINCIPAL ---
while true; do
    raw=$(get_input "1-Red 2-Sis 3-Admin 4-Jugar 5-Fin")
    
    if [ -z "$raw" ]; then
        run_terminal "neofetch"
        continue
    fi

    sel=$(clean_input "$raw"); sel=${sel: -1}

    case "$sel" in
        1) menu_network ;;
        2) menu_system ;; 
        3) menu_admin ;;
        4) launch_games ;;
        5) 
           off=$(get_input "1-Apagar 2-Reiniciar")
           c_off=$(clean_input "$off"); c_off=${c_off: -1}
           if [ "$c_off" == "1" ]; then poweroff; fi
           if [ "$c_off" == "2" ]; then reboot; fi
           ;;
        *) ;;
    esac
done
