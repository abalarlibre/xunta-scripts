#!/bin/bash
#*********************************************************************************#
# Copyright (C) 2019, Xunta de Galicia for Consolidacion Software Abalar          #
# Project <software.libre@edu.xunta.es>                                           #
# Author: Alfonso Bilbao Velez <alfonso.ernesto.bilbao.velez.ocampo@everis.com>   #
# Name: auto_apagado_abalar.sh                                                    #
# Description: Menu selector de opciones para el programador de horas y minutos   # 
# para el apagado automático.                                                     #
# Funciones: - programar_apagado_diario                                           #
#	     - desprogramar_apagado                                               #
#	     - comprobar_horas_programadas                                        #
#                                                                                 #
# Developed by EVERIS S.L.U.                                                      #
#*********************************************************************************#

# FUNCIONES.
# PROGRAMAR APAGADO.
programar_apagado_diario(){
# Usuario.
USER=$(whoami)

# Tiene permisos de ejecucion.
if test $USER = "root"; then
	#Comprobamos las horas de apagado ya programadas:
	if cat /etc/cron.d/auto_apagado | grep -v "^#" | grep "^.*cuentaatras" &> /dev/null ; then
		# Detectar Programado previo. Almacenar en variable auxiliar.
		cat /etc/cron.d/auto_apagado \
			| grep -v "^#" \
			| grep "^.*cuentaatras" \
			| awk -F " " '{ print $2 ":" $1}' > /tmp/aux-comprobar-apagado
		# Mensaje.
		TEXTO="\n Xa hai programadas as seguintes horas de apagado: \n <b>$(cat /tmp/aux-comprobar-apagado)</b> \n Indica a continuación a hora de apagado desexada, e se queres manter as horas xa programadas: \n"
	else
		# Mensaje.
		TEXTO="\n Non hai ningunha hora de apagado programada. \n Indica a hora de apagado desexada: \n"
	fi
	# Reprogramar nuevo apagado. 
	RES=$(yad --title="Editor de apagado" --center --title "Programar Apagado" \
		  --width="500" \
		  --window-icon=/usr/share/icons/hicolor/256x256/devices/auto_apagado_abalar.png \
		  --text-align center \
		  --text="$TEXTO" \
		  --form --field="Hora:NUM" 0!0..23!1  --field="Minutos:NUM" 0!0..59!5 \
		  --field="¿Manter as horas de apagado xa programadas?:CHK" TRUE \
		  --button="gtk-ok:0" --button="Cancelar:1")

	if [ "$?" = "0" ]; then
		HORA=$(echo "$RES" | cut -d"|" -f1 | cut -d"," -f1)
		MINUTOS=$(echo "$RES" | cut -d"|" -f2 | cut -d"," -f1)
		MANTENERHORASPROGRAMADAS=$(echo "$RES" | cut -d"|" -f3 | cut -d"," -f1)

		if test "$MANTENERHORASPROGRAMADAS" == "TRUE" ; then
			# Mantener horas programadas previamente sin repetir las mismas horas.
			#echo "$MINUTOS $HORA * * * root export DISPLAY=:0 && su usuario -c 'sudo /opt/auto_apagado/bin/cuentaatras'" >> /etc/cron.d/auto_apagado
			grep -F "$MINUTOS $HORA * * * usuario /opt/auto_apagado/bin/cuentaatras" /etc/cron.d/auto_apagado||
			echo "$MINUTOS $HORA * * * usuario /opt/auto_apagado/bin/cuentaatras" >> /etc/cron.d/auto_apagado
		else
			# Eliminar horas programadas previamente.
			#echo "$MINUTOS $HORA * * * root export DISPLAY=:0 && su usuario -c 'sudo /opt/auto_apagado/bin/cuentaatras'" > /etc/cron.d/auto_apagado
			echo "$MINUTOS $HORA * * * usuario /opt/auto_apagado/bin/cuentaatras" > /etc/cron.d/auto_apagado
		fi
	fi
	comprobar_horas_apagado

# No tiene permisos de ejecucion.
else
	yad --title "Programar Apagado" --info --text "Non tes permisos para executar o programa." \
	    --window-icon=/usr/share/icons/hicolor/256x256/devices/auto_apagado_abalar.png \
	    --width="400" \
	    --height="100" \
	    --center --justify="center" --text-align="center"
fi
}

# DESPROGRAMAR APAGADO.
desprogramar_apagado(){
# User.
USER=$(whoami)

# Tiene permisos de ejecucion.
if test $USER = "root"; then
	# Mensaje usuario.
	if zenity --question --text "¿Desexa desactivar o apagado automático?" --width=300 --height=100 --ok-label="Aceptar" --cancel-label="Cancelar";then
		if test -f /etc/cron.d/auto_apagado ; then
			echo "#Autoapagado Desprogramado." > /etc/cron.d/auto_apagado
			#exit 0
		fi
	fi

# Sin permisos de ejecucion.
else
	yad --title "Desprogramar apagado" \
	    --info --text " Non tes permisos para executar este programa." \
	    --window-icon=/usr/share/icons/hicolor/256x256/devices/auto_apagado_abalar.png \
            --width="400" \
	    --height="100" \
	    --center --justify="center" --text-align="center"
fi
}

# COMPROBAR HORAS APAGADO.
comprobar_horas_apagado(){
# Comrobar si existe un cron.
if test -f /etc/cron.d/auto_apagado ; then
	# No hay apagados programados.
	if ! test $(cat /etc/cron.d/auto_apagado \
		| grep -v "^#" \
		| grep "^.*cuentaatras" | wc -l | tee /tmp/nlineas) -ge 1 ; then
		TEXTO="<b>Non hai programado ningún apagado</b>"
	else
	# Existen horarios programados.
		cat /etc/cron.d/auto_apagado \
			| grep -v "^#" \
			| grep "^.*cuentaatras" \
			| awk -F " " '{ print $2 ":" $1}' > /tmp/aux-comprobar-apagado
		TEXTO="<b>$(cat /tmp/aux-comprobar-apagado)</b>"
	fi
	# Mensaje a usuario.
	yad --title="Horas de apagado programadas." \
            --image  /usr/share/icons/hicolor/22x22/status/xfpm-ac-adapter.png \
            --info --text "As horas de apagado programadas son: \n $TEXTO" \
	    --center \
            --window-icon=/usr/share/icons/hicolor/256x256/devices/auto_apagado_abalar.png \
            --width="350" \
	    --height="100" \
	    --text-align="center" \
            --button="gtk-ok:0" \
	    --button="Programar Novo Apagado:1"

	[ "$?" = 1 ] && programar_apagado_diario
fi
}

# MAIN #
main(){
# Variables.
Titulo="Programar Auto Apagado"
Pregunta="Selecciona una opcion:"
Opciones=("Programar Apagado" "Desprogramar Apagado" "Comprobar Horas Programadas" "Finalizar")

# Bucle.
while opcion="$(zenity --title="$Titulo" \
		       --text="$Pregunta" \
		       --width=300 --height=220 \
		       --window-icon=/usr/share/icons/hicolor/256x256/devices/auto_apagado_abalar.png \
		       --list --column="Opciones" "${Opciones[@]}")"; do

	# Selector.
	case $opcion in
	# Programar Apagado.
	"${Opciones[0]}" ) 
        	#echo "Has elegido $opt, Programar Apagado"
        	#zenity --info --text="Has elegido $opt, Programar Apagado"
		programar_apagado_diario
        ;;

	# Desprogramar Apagado.
	"${Opciones[1]}") 
        	#echo "Has elegido $opt, Desprogramar Apagado"
        	#zenity --info --text="Has elegido $opt, Desprogramar Apagado"
		desprogramar_apagado
        ;;

	# Comprobar Horas Programadas
	"${Opciones[2]}") 
        	#echo "Has elegido $opt, Comprobar Horas Programadas"
       		#zenity --info --text="Has elegido $opt, Comprobar Horas Programadas"
		comprobar_horas_apagado
        ;;

	# Finalizar Programacion.
	"${Opciones[3]}") 
        	#echo "Esta seguro que queres $opt, Finalizar."
       		zenity --question --text="Realmente queres $opt, rematar." --width=300 --height=100 --ok-label="Aceptar" --cancel-label="Cancelar"
		if [[ $? -eq 0 ]];then
			exit 0
		fi
        ;;

    "${Opciones[-1]}") 
        zenity --error --text="Opcion Incorrecta , proba con outra." --width=300 --height=100
        ;;
    esac
done
}

main
