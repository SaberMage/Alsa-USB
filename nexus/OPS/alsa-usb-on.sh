#!/bin/bash

TARGET_CARD=usb
AU_VARS=/opt/alsa-usb/cur-scard.sh

[[ -f $AU_VARS ]] && . $AU_VARS #Pull in sound card vars
if [ ! -f $AUTO_DISABLE ] && [ $SOUND_CARD != $TARGET_CARD ]; then
	SOUND_CARD=$TARGET_CARD && CARD_EVENT=1
fi
USB_EXIST=1 && . $WRITE_VARS
