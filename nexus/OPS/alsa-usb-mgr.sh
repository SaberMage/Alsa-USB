#!/bin/bash

AU_VARS=/opt/alsa-usb/cur-scard.sh
ALSASWITCHES=/usr/local/sbin/alsaswitches
ALSASWITCH=/usr/local/sbin/alsaswitch
BGM_PLAYER=/home/pi/RetroPie-BGM-Player/bgm_system.sh
BGM_TEST="$(sudo ps -e | grep audacious > /dev/null && echo 1 || echo 0)"
CARD_EVENT=0 #Default

#End script if auto-switching is off
[ -e $AU_VARS ] && . $AU_VARS && [ -e $AUTO_DISABLE ] && exit

while [ 1 ]; do
	#Load LATEST info about the current state of the sound card
	[ -e $AU_VARS ] && . $AU_VARS
	if [ $CARD_EVENT == 1 ]; then
		NEW_CARD=$SOUND_CARD
		printf "\n>> Requested audio device: ${SOUND_CARD}\n"
		#Special condition: BGM running in AU menu -- reset it upon auto-switch
		if [ -e $GAME_DISABLE ] && [ $BGM_TEST == 1 ]; then
			printf "\n>> Passed BGM test\n"
			$ALSASWITCH $SOUND_CARD & #> /dev/null &
			sleep 1
			[[ -e $BGM_PLAYER ]] && sudo -u pi $BGM_PLAYER -r #&> /dev/null &
		else
			#If playing game, change sound card when game ends
			while [ -e $GAME_DISABLE ]; do sleep 0.2; done
			. $AU_VARS #Reload sound card vars in case they changed
			printf "\n>> Acknowledged request\n>> Updated audio device: ${SOUND_CARD}\n>> Old requested device: ${NEW_CARD}\n"
			if [ $SOUND_CARD == $NEW_CARD ] || [ $SOUND_CARD == "usb" ]; then
				#Card change request stayed the same or is USB; need to reboot processes
				$ALSASWITCHES $SOUND_CARD & #> /dev/null &
			else
				#Card change request was effectively revoked; alsaswitch unsets $CARD_EVENT
				$ALSASWITCH $SOUND_CARD & #> /dev/null &
			fi
		fi
	fi
	sleep 0.5
done
