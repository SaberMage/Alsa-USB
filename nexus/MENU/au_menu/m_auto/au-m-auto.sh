#!/bin/bash 
#####################################################################
#Project		:	Alsa-USB
#Git			:	https://github.com/
#####################################################################
#Script Name	:	au-m3.sh
#Date			:	20210307	(YYYYMMDD)
#Description	:	Alsa-USB toggle menu for auto-switching
#Usage		:	To be called by au-menu-top.sh
#Author       	:	Reavo End (Brandon Smith)
#####################################################################
#Menu Base	:	Naprosnia : https://github.com/naprosnia
#####################################################################

OPS=/opt/alsa-usb
AU_VARS=$OPS/cur-scard.sh
AU=/home/pi/Alsa-USB
VERSION=$AU/version.sh && . $VERSION

function main_menu() {
	local choice
	local status
	local option

    while true; do
		. $AU_VARS #Keep sound card vars updated
	
		#Set toggleable elements
		if [ ! -f $AUTO_DISABLE ]; then
			#IDs:		Cur State	Togg State
			status=(	"ON"		"* Disable"	)
		else
			status=(	"OFF"		"* Enable"	)
		fi
		status[0]="${status[0]}\n\nNOTE: This feature works outside of gameplay *only!*"
		
		#Set option text
		option="${status[1]} Auto-Switch"
		
		#The menu itself (via this subshell 'dialog' command)
        choice=$(dialog --backtitle "Alsa-USB v. $au_version" --title "Automatic Device Switching" \
            --ok-label "Select" --cancel-label "Back" --no-tags \
            --menu "Audio device auto-switching is ${status[0]}" 25 75 20 \
            1 "${option}" \
            2>&1 > /dev/tty)

        opt=$?
		[ $opt -eq 1 ] && exit
		
		
		#Toggle existence of auto-switch.disable
		if [ -f $AUTO_DISABLE ]; then
			sudo rm $AUTO_DISABLE
			sudo $OPS/alsa-usb-mgr.sh &> /dev/null &
		else
			sudo touch $AUTO_DISABLE
			sudo pkill -f alsa-usb-mgr
		fi
		
		
    done
}

main_menu
