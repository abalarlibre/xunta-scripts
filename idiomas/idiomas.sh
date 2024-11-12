#!/bin/bash

(
zenity --warning --title="Cambio de idioma do sistema" --width=400 --text="Ao finalizar o proceso de cambio de idioma a sesión de usuario será reiniciada. 
<b>Garda todos os proxectos que teñas en execución para non perder os datos</b>"

echo "10"
echo "# Escollendo o idioma do sistema"
sleep 1
# Perguntar que idioma se quere instalar/configurar
IDIOMA_ACTUAL=$(grep LANG= /etc/default/locale | cut -d "=" -f2)
DISPOSICION_ACTUAL=$(grep preload /home/usuario/.config/dconf/dump.dconf | cut -d '=' -f2 | sed s/"\["/""/ | sed s/"\]"/""/)
IDIOMA=$(zenity --list --title="Escoller idioma" --height=200 --width=100 --ok-label="Escoller"  --cancel-label="Cancelar" --text="Selecciona o idioma no que queres configurar o sistema, ou cancela para abortar esta execución" --radiolist --column="" --column="Idioma" 1 "Galego" 2 "Ruso" 3 "Ucraíno" 4 "Eslovaco")
#Em funçom do valor de idioma, aplica os cambios correspondentes, ou sae se se cancela a operaçom
if [[ $? -ne 0 ]]
	then
		echo "# Proceso cancelado"
		sleep 2
    		exit
elif [[ $IDIOMA = "Galego" ]]
	then
		IDIOMA_FINAL="gl_ES.UTF-8"
		LOCALE_GEN="gl_ES.UTF-8\ UTF-8"
		CHROME_ACTUAL="Exec=env \/usr\/bin\/google-chrome-stable"
		CHROME_FINAL="Exec=env LANGUAGE=es \/usr\/bin\/google-chrome-stable"
		DISPOSICION_FINAL="'xkb:es::spa', 'xkb:gr::ell', 'xkb:pt::por', 'xkb:us::eng'"
		PAQUETE_FIREFOX="firefox-esr-l10n-gl"
		PAQUETE_LIBREOFFICE="libreoffice-l10n-gl"
		echo $LOCALE_GEN
elif [[ $IDIOMA = "Ruso" ]]
	then
		IDIOMA_FINAL="ru_UA.UTF-8"
		LOCALE_GEN="ru_UA.UTF-8\ UTF-8"
		CHROME_ACTUAL="LANGUAGE=es "
		CHROME_FINAL=""
		DISPOSICION_FINAL="'xkb:ua:rstu_ru:ukr', 'xkb:es::spa', 'xkb:gr::ell', 'xkb:pt::por', 'xkb:us::eng'"
		PAQUETE_FIREFOX="firefox-esr-l10n-ru"
		PAQUETE_LIBREOFFICE="libreoffice-l10n-ru"
		echo $LOCALE_GEN
elif [[ $IDIOMA = "Ucraíno" ]]
	then
		IDIOMA_FINAL="uk_UA.UTF-8"
		LOCALE_GEN="uk_UA.UTF-8\ UTF-8"
		CHROME_ACTUAL="LANGUAGE=es "
		CHROME_FINAL=""
		DISPOSICION_FINAL="'xkb:ua::ukr', 'xkb:es::spa', 'xkb:gr::ell', 'xkb:pt::por', 'xkb:us::eng'"
		PAQUETE_FIREFOX="firefox-esr-l10n-uk"
		PAQUETE_LIBREOFFICE="libreoffice-l10n-uk"
		echo $LOCALE_GEN
elif [[ $IDIOMA = "Eslovaco" ]]
	then
		IDIOMA_FINAL="sk_SK.UTF-8"
		LOCALE_GEN="sk_SK.UTF-8\ UTF-8"
		CHROME_ACTUAL="LANGUAGE=es "
		CHROME_FINAL=""
		DISPOSICION_FINAL="'xkb:sk::slk', 'xkb:es::spa', 'xkb:gr::ell', 'xkb:pt::por', 'xkb:us::eng'"
		PAQUETE_FIREFOX="firefox-esr-l10n-sk"
		PAQUETE_LIBREOFFICE="libreoffice-l10n-sk"
		echo $LOCALE_GEN

fi

echo "30"
echo "# Instalando paquetes de idioma"

VERSION_FIREFOX=$(apt-cache policy firefox-esr | head -n2 | tail -n1 | cut -d ' ' -f4)
VERSION_LIBREOFFICE=$(apt-cache policy libreoffice | head -n2 | tail -n1 | cut -d ' ' -f4)

/usr/bin/apt update &> /dev/null
apt install -y $PAQUETE_FIREFOX=$VERSION_FIREFOX $PAQUETE_LIBREOFFICE=$VERSION_LIBREOFFICE
INSTALACION=$?
while [ ! $INSTALACION -eq 0 ]; do
	zenity --question --title="Erro durante a instalación" --height=100 --width=400  --text="Ocorreu un problema durante a instalación.\nVerifica que tes conexión a internet.\nVolver a intentar?" --ok-label="Si" --cancel-label="Cancelar"
	if [[ ! $? -eq 0 ]];then
		echo "# Proceso cancelado"
		sleep 2
    	exit
	else
		/usr/bin/apt update &> /dev/null
		apt install -y $PAQUETE_FIREFOX=$VERSION_FIREFOX $PAQUETE_LIBREOFFICE=$VERSION_LIBREOFFICE &> /dev/null
	fi
	INSTALACION=$?
done

echo "50"
echo "# Configurando o sistema co idioma $IDIOMA"
sleep 2
#echo -e "\e[1;36mXerando o idioma $IDIOMA no sistema\e[0m"
# Xerar o locale escolhido por se ainda nom estivera disponível no sistema
sed -i "s/#\ $LOCALE_GEN/$LOCALE_GEN/g" /etc/locale.gen
locale-gen &> /dev/null

# Estabelecer o idioma escolhido como idioma por defecto do sistema
sed -i "s/LANG=$IDIOMA_ACTUAL/LANG=$IDIOMA_FINAL/g" /etc/default/locale
update-locale 

echo "60"
echo "# Configurando o google chrome"
sleep 2
# Cambiar a execuçom do google chrome, que em galego está forçada ao Castelhano
sed -i "s/$CHROME_ACTUAL/$CHROME_FINAL/g" /home/usuario/.local/share/applications/google-chrome.desktop
sed -i "s/$CHROME_ACTUAL/$CHROME_FINAL/g" /home/usuario/.config/xfce4/panel/launcher-4/panel_chrome.desktop
sed -i "s/$CHROME_ACTUAL/$CHROME_FINAL/g" /usr/share/applications/google-chrome.desktop

echo "80"
echo "# Cambiando a disposición do teclado"
echo -e "\e[1;36mCambiando a disposición do teclado\e[0m"
sleep 2
## Cambio na disposición do teclado em sessom
# Cambia o modelo
sed -i "s/$DISPOSICION_ACTUAL/$DISPOSICION_FINAL/g" /home/usuario/.config/dconf/dump.dconf
# Restaura as configuraçons de dconf cos cambios feitos, para xfce
su usuario -c "export DISPLAY=:0; export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; /usr/bin/dconf load /desktop/ibus/ < /home/usuario/.config/dconf/dump.dconf"
su usuario -c "export DISPLAY=:0; export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; /usr/bin/ibus-daemon -r &"



echo "100"
echo "# Rematando a configuración";sleep 2
# Avisa de que se vai reiniciar a sessom de usuário
zenity --warning --title="Cambio de idioma do sistema" --width=400 --text="O sistema foi configurado en <b>$IDIOMA</b>. Para facer efectivos os cambios vaise reiniciar a sesión de usuario.\n<b>Lembra gardar o teu traballo se non o fixeches anteriormente.</b>"

# Reinicia o serviço de lightdm
systemctl restart lightdm.service

) |
zenity --progress --no-cancel --width=400 --title="Cambio de idioma" --text="Iniciando o proceso" --percentage=0

