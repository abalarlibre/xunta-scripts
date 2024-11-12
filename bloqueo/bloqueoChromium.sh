#!/bin/bash
# Copyright (C) 2024, Xunta de Galicia for Consolidación Software Abalar
# Project <software.libre@edu.xunta.es>
# developed by NTTData
#
d_chromium="/home/usuario/.config/chromium"
if [ -d $d_chromium ]; then 
	pro_chromium=$(stat -c "%U" $d_chromium)
	if [ "$pro_chromium" = "usuario" ] ; then
		chown -R root:root $d_chromium
		chmod -R 700 $d_chromium
	fi
fi

