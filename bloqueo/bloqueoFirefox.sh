#!/bin/bash
# Copyright (C) 2024, Xunta de Galicia for Consolidación Software Abalar
# Project <software.libre@edu.xunta.es>
# developed by NTTData
#
#  Bloquear perfiles en firefox
# Variables
d_archivos="/opt/bloqueo/mozilla"
d_mozilla="/home/usuario/.mozilla/firefox"
a_profile="profiles.ini"
a_install="installs.ini"
hash_install=$(md5sum $d_archivos/$a_install | cut -d ' ' -f 1)
# Lógica
if [ -d $d_mozilla ]; then
	if [ -f $d_mozilla/$a_profile ]; then
		# Se comprueba si el archivo profile esta bien configurado
		hash_profile_viejo=$(md5sum $d_mozilla/$a_profile | cut -d ' ' -f 1) # Generado por el propio firefox
		d_perfil_viejo=$(find $d_mozilla -name *.default) # Ruta absoluta del direcorio del perfil por defecto
		d_perfil_nombre=$(echo $d_perfil_viejo | cut -d '/' -f 6) # Solo el nombre del direcorio para pasarlo al profile.ini
		hash_profile_nuevo=$(sed "s/XX/$d_perfil_nombre/g" $d_archivos/$a_profile | md5sum | cut -d ' ' -f 1) # El profile.ini que tiene que estar
		# Comprobacion del archivo profiles.ini por si ya es igual
		if [ $hash_profile_nuevo != $hash_profile_viejo ]; then
			# Se le sobreescribe el profile con el nombre del perfil por defecto
			sed "s/XX/$d_perfil_nombre/g" $d_archivos/$a_profile > $d_mozilla/$a_profile
			chown root:usuario $d_mozilla/$a_profile
			chmod 644 $d_mozilla/$a_profile
		fi
	fi
	# Comprobacion del archivo installs.ini por si ya es igual
	if [ -f $d_mozilla/$a_install ]; then
		hash_install_viejo=$(md5sum $d_mozilla/$a_install | cut -d ' ' -f 1)
		if [ $hash_install != $hash_install_viejo ]; then
			cp $d_archivos/$a_install $d_mozilla/$a_install
			chown root:usuario $d_mozilla/$a_install
			chmod 644 $d_mozilla/$a_install
		fi
	else
		cp $d_archivos/$a_install $d_mozilla/$a_install
		chown root:usuario $d_mozilla/$a_install
		chmod 644 $d_mozilla/$a_install 
	fi
fi
