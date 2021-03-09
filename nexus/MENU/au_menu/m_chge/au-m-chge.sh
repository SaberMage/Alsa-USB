#!/bin/bash 
#####################################################################
#Project		:	Alsa-USB
#Git			:	https://github.com/
#####################################################################
#Script Name	:	au-m1.sh
#Date			:	20210306	(YYYYMMDD)
#Description	:	Alsa-USB menu for audio device change
#Usage		:	To be called by au-menu-top.sh
#Author       	:	Reavo End (Brandon Smith)
#####################################################################
#Menu Base	:	Naprosnia : https://github.com/naprosnia
#####################################################################

OPS=/opt/alsa-usb
AU_VARS=$OPS/cur-scard.sh
AU=/home/pi/Alsa-USB
VERSION=$AU/version.sh && . $VERSION
ALSASWITCH=/usr/local/sbin/alsaswitch
BGM_PLAYER=/home/pi/RetroPie-BGM-Player/bgm_system.sh

function main_menu() {
	local choice
	local status
	local option
	local oklabel

    while true; do
		. $AU_VARS #Keep sound card vars updated
			
		#Set toggleable elements
		if [ $SOUND_CARD == "usb" ]; then
			#IDs:		Active		Inactive	Code
			status=(	"USB"		"Onboard"	"onboard"	)
		elif [ $USB_EXIST == 1 ]; then
			status=(	"Onboard"	"USB" 	"usb"		)
		else
			status=(	"Onboard"	"N/A"		"na"		)
		fi
		#If set to USB but USB is d/ced, indicate that much
		if [ ${status[0]} == "USB" ] && [ $USB_EXIST == 0 ]; then
			status[0]="USB (disconnected)"
		fi
		
		#Set option text
		if [ ${status[2]} != "na" ]; then
			option="* ${status[1]} Audio, Go !!"
			oklabel="Select"
		else
			option="* No USB audio device detected!"
			oklabel="Refresh"
		fi
		
		#The menu itself (via this subshell 'dialog' command)
        choice=$(dialog --backtitle "Alsa-USB v. $au_version" --title "Toggle USB Output" \
            --ok-label "${oklabel}" --cancel-label "Back" --no-tags \
            --menu "Current audio device is: ${status[0]}" 25 75 20 \
            1 "${option}" \
            2>&1 > /dev/tty)

        opt=$?
		[ $opt -eq 1 ] && exit
		
		
		if [ ${status[2]} != "na" ]; then
			. $AU_VARS #Keep sound card vars updated
			#Only switch to USB if it's connected; always permit switch to onboard
			if [ $USB_EXIST == 1 ] || [ ${status[2]} == "onboard" ]; then
				#Switch sound card profiles, restart BGM
				$ALSASWITCH ${status[2]} &> /dev/null
				sleep 1 #To be safe
				[[ -f $BGM_PLAYER ]] && $BGM_PLAYER -i &> /dev/null &
			fi
		fi
		
		
    done
}

main_menu
