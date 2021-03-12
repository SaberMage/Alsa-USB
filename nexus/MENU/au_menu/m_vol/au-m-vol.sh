#!/bin/bash 
#####################################################################
#Project		:	Alsa-USB
#Git			:	https://github.com/
#####################################################################
#Script Name	:	au-m2.sh
#Date			:	20210307	(YYYYMMDD)
#Description	:	Alsa-USB menu for USB sound card volume management
#Usage		:	To be called by au-menu-top.sh
#Author       	:	Reavo End (Brandon Smith)
#####################################################################
#Menu Base	:	Naprosnia : https://github.com/naprosnia
#####################################################################

OPS=/opt/alsa-usb
AU_VARS=$OPS/cur-scard.sh
AU=/home/pi/Alsa-USB
VERSION=$AU/version.sh && . $VERSION
. $AU/usb.f #Source USB functions
USB_EXIST=0 #Default

function main_menu() {
    local choice
	local curvol
	local mctrl
	local opts

    while true; do
		. $AU_VARS #Keep sound card vars updated
		if [ $USB_EXIST == 0 ]; then
			curvol="n/a"
			mctrl="PCM" #Placeholder
			choice=$(dialog --backtitle "Alsa-USB v. $au_version" --title "USB Volume Control" \
            --ok-label "Refresh" --cancel-label "Back" --no-tags --default-item "$curvol"\
            --menu "Modify volume level -- Current: ${curvol}%" 25 75 20 \
				404 "* No USB audio device detected!" \
            2>&1 > /dev/tty)
		else
			curvol=$(usbgetvol) #Get USB volume %
			mctrl=$(usbcontrolname) #Get USB mixer control name
			choice=$(dialog --backtitle "Alsa-USB v. $au_version" --title "USB Volume Control" \
            --ok-label "Select" --cancel-label "Back" --no-tags --default-item "$curvol"\
            --menu "Modify volume level -- Current: ${curvol}%" 25 75 20 \
				999 "I Interactive Mixer" \
				100 "1 Volume 100%" \
				90 "2 Volume 90%" \
				80 "3 Volume 80%" \
				70 "4 Volume 70%" \
				60 "5 Volume 60%" \
				50 "6 Volume 50%" \
				40 "7 Volume 40%" \
				30 "8 Volume 30%" \
				20 "9 Volume 20%" \
				10 "A Volume 10%" \
				0 "M Mute" \
            2>&1 > /dev/tty)
		fi
			
		opt=$?
		[ $opt -eq 1 ] && exit
			
			
		if [ $choice != 404 ] && [ $choice != 999 ]; then
			#printf "\nDEBUG\nmctrl=${mctrl}\nopt=${choice}\n"
			#Set the volume percentage. For most devices, the outcome is off by 1-2%
			amixer -c USB_AUD sset "$mctrl" "${choice}%"
		elif [ $choice == 999 ]; then
			alsamixer -c USB_AUD
		fi
			
			
    done
}

main_menu

