#!/bin/bash
#Runs at boot time via alsa-usb-init.service
AU_VARS=/opt/alsa-usb/cur-scard.sh
ALSASWITCH=/usr/local/sbin/alsaswitch

#Ensure game disable lock is off
sudo rm /opt/alsa-usb/game-on.disable &> /dev/null

#Load in + reset sound card vars
. $AU_VARS
USB_EXIST=0 && SOUND_CARD=onboard && CARD_EVENT=1
systemctl | grep usb.*sound-card > /dev/null && USB_EXIST=1
[ $USB_EXIST == 1 ] && [ ! -e $AUTO_DISABLE ] && SOUND_CARD=usb && $ALSASWITCH usb
. $WRITE_VARS

exit 0
