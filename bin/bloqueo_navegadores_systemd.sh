#!/bin/bash

# Copyright (C) 2024, Xunta de Galicia for Consolidación Software Abalar
# Project <software.libre@edu.xunta.es>
# developed by NTTData

LOG_FILE="/var/log/bloqueo_navegadores.log"
export DISPLAY=:0.0

# Listado de palabras chave de procesos que queremos bloquear

KEYWORDS=(
    "opera" "brave" "vivaldi" "edge" "chrome" "firefox"
    "safari" "chromium" "catalyst" "agregore" "cromite" "deskreen" "dezor" 
    "elza" "fiery-maui" "fifo" "firedragon" "floorp" "galacteek" 
    "godmode" "icecat" "kristall" "librewolf" "mercury" "midory" 
    "mullvad" "ncsa" "palemoon" "polypane" "promethium" "responsively" 
    "theweb" "thorium" "viper"  "wexond" "waterfox" "tor-browser"
) 
# firefox.real é o proceso de tor-browser, non sei... eu xa...
# mullvadbrowser.real é o processo do mullvad

# Lista de excepciones, en este caso procesos que no deben ser terminados
EXCEPTIONS=(
    
)

circuncidar_servizo() {
    
    PID=$1
    PID_NAME=$2

    echo "$(date) - Matando proceso: PID $PID, Nome: $PID_NAME" >> "$LOG_FILE"
    kill -9 "$PID" > /dev/null 2>&1
    su - usuario -c "DISPLAY=$DISPLAY zenity --error --text='Este tipo de software non está permitido.' --title='AVISO' --width=300 &" 
    sleep 2
    
}

while true; do

    # Listado de procesos que conteña algo relacionado con calqueira das keywords,
    # Coa exclusión dos procesos concretos que haxa definidos en exceptions
    list=$(ps -eo pid,comm --no-headers | awk '{print $1" "$2}'\
            | grep -iE "$(for keyword in "${KEYWORDS[@]}"; do echo -n "$keyword|"; done | sed 's/|$//')"\
            #| grep -Ev "$(for exception in "${EXCEPTIONS[@]}"; do echo -n "$exception|"; done | sed 's/|$//')"
            )


    if [ -n "$list" ]; then

        while read pid process_name; do
            
            # Buscamos o arquivo dende onde se executa
            loc=$(readlink -f /proc/$pid/exe) 

            # Se non se atopa, presupónse que é unha Appimage dende /home
            if [ -z "$loc" ]; then
                mount_point=$(cat /proc/$pid/cmdline 2>/dev/null | cut -d'/' -f1-3) 
                file=$(mount | grep "$mount_point" | awk '{print $1}' 2>/dev/null)
                loc=$(find /home /media /tmp -type f -name "$file" 2>/dev/null)
            fi
            
            # Con esto evitamos que os nenos vexan porno a futuro 
            if [ -n "$loc" ] && [ -e "$loc" ]; then

                loc_dir=$(dirname "$loc")
                if [[ "$loc_dir" == /home* || "$loc_dir" == /tmp* || "$loc_dir" == /media* ]]; then

                    echo "$(date) - Quitando permisos a $loc" >> "$LOG_FILE"
                    chmod -x "$loc" > /dev/null 2>&1
                    chown root:root "$loc" > /dev/null 2>&1
                    circuncidar_servizo "$pid" "$process_name"
                fi

            else
                echo "$(date) - Non se atopou ningún arquivo válido referido ao proceso $process_name" >> "$LOG_FILE"
                circuncidar_servizo "$pid" "$process_name"
            fi

            # Como non logro actualizar a $list do bucle, actualizo esta, ao quedar vacía acaba o bucle
            list=$(echo "$list" | grep -v "$process_name")
            if [ -z "$list" ]; then
                break
            fi

        done <<< "$list"
    fi

    # Tempo susceptible de cambio 
    sleep 5

done

# arqpyb


