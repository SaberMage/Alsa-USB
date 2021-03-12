#!/bin/bash
#####################################################################
#Project		:	Alsa-USB
#Git			:	https://github.com/
#####################################################################
#Script Name	:	usb.f
#Date			:	20210307	(YYYYMMDD)
#Description	:	A few handy USB audio-related functions
#Usage		:	Source with '.' or 'source' before calling funcs
#Author       	:	Reavo End (Brandon Smith)
#####################################################################

function usbgetvol() {
	local curvol
	
	#Isolate the string(s) with a volume %
	curvol=$(amixer -c USB_AUD | grep '%')
	#Store the first volume level
	curvol=$(echo $curvol | cut -d '[' -f 2 | cut -d '%' -f 1)
	
	[[ ! -z $curvol ]] && echo $curvol || echo "n/a"
}

function usbcontrolname() {
	local mctrl

	#Isolate the mixer control string(s)
	mctrl=$(amixer -c USB_AUD | grep "mixer control")
	#Store the first mixer control name found
	mctrl=$(echo $mctrl | cut -d "'" -f 2)
	
	echo $mctrl
}