#!/bin/bash 
#####################################################################
#Project		:	Alsa-USB
#Git			:	https://github.com/
#####################################################################
#Script Name	:	au-menu-top.sh
#Date			:	20210306	(YYYYMMDD)
#Description	:	Alsa-USB settings main menu
#Usage		:	To be called by Alsa-USB.sh
#Author       	:	Reavo End (Brandon Smith)
#####################################################################
#Menu Base	:	Naprosnia : https://github.com/naprosnia
#####################################################################

# Prep menu layer paths
AU=/home/pi/Alsa-USB
AU_MENU=$AU/au_menu
M_CHGE=$AU_MENU/m_chge/au-m-chge.sh
M_VOL=$AU_MENU/m_vol/au-m-vol.sh
M_AUTO=$AU_MENU/m_auto/au-m-auto.sh
VERSION=$AU/version.sh && . $VERSION
. $AU/usb.f #Source USB functions
OPS=/opt/alsa-usb
AU_VARS=$OPS/cur-scard.sh

function main_menu() {
    local choice
	local h_cnx
	local h_curvol
	local h_usb
	local h_switch
	local header
	
	. $AU_VARS #Load sound card vars
	#Ensure auto sound card changes don't happen while in menu
	sudo touch $GAME_DISABLE

    while true; do
		. $AU_VARS #Keep sound card vars updated
		
		#Update header display
		[[ $USB_EXIST == 1 ]] && h_cnx="Connected" || h_cnx="None"
		h_curvol=$(usbgetvol) #Get USB volume %
		[[ $SOUND_CARD == "usb" ]] && h_usb="ON" || h_usb="OFF"
		[[ -f $AUTO_DISABLE ]] && h_switch="OFF" || h_switch="ON"
		header="USB: ${h_cnx} // USB Audio: ${h_usb} // Volume: ${h_curvol}% // Auto: ${h_switch}"
		
		#The menu itself (via this subshell 'dialog' command)
        choice=$(dialog --backtitle "Alsa-USB v. $au_version" --title "Main Menu" \
            --ok-label "Select" --cancel-label "Exit" --no-tags \
            --menu "${header}" 25 75 20 \
			"$M_VOL" "1 USB Volume" \
			"$M_CHGE" "2 Toggle USB Output" \
			"$M_AUTO" "3 Device Auto-Switching" \
            2>&1 > /dev/tty)
		
		opt=$?
		if [ $opt -eq 1 ]; then
			#Upon exit, dismantle card event & restart ES
			. $AU_VARS && CARD_EVENT=0 && . $WRITE_VARS
			#Reenable auto sound card changes
			sudo rm $GAME_DISABLE &> /dev/null
			sudo pkill -f emulationstatio
			printf "\n\n*** Applying any audio output changes... ***\n\n"
			sleep 1.5 #Starting up ES too soon results in ENDLESS ERRORS
			sudo sh -c 'openvt -fc 1 emulationstation - pi' #Make sure ES runs in TTY1
			exit
		fi
		
        bash $choice
		
    done
}

while [ 1 == 1 ]; do
	main_menu
done
