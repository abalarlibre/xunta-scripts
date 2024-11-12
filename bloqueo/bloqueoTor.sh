#!/bin/bash
# Copyright (C) 2024, Xunta de Galicia for Consolidación Software Abalar
# Project <software.libre@edu.xunta.es>
# developed by NTTData
#
a_tor=$(find / -name *profiles.ini* -user "usuario" -not -path "*/m11_bloqueo_navegadores/*" 2> /dev/null | grep -ie "tor" -ie "browser") # Variable con el archivo de los perfiles de tor
d_tor=$(find / -type d -name "tor-browser" -user "usuario" 2> /dev/null) # Variable con el directorio de tor
if [ ! -v $a_tor ]; then
	pro_a_tor=$(stat -c "%U" $a_tor)
	if [ "$pro_a_tor" != "root" ]; then
		# Se cambia el propietario de root y permisos
		chown -R root:root $a_tor
		chmod -R 700 $a_tor
	fi
fi
if [ ! -v $d_tor ]; then # Si no esta vacia y el propietario no es root
	pro_d_tor=$(stat -c "%U" $d_tor)
	if [ "$pro_d_tor" != "root" ]; then
	# Se cambia el propietario a root y los permisos
		chown -R root:root $d_tor
		chmod -R 700 $d_tor
	fi
fi
