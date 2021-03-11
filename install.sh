#!/bin/bash
#####################################################################
#Project        : Alsa-USB
#Version        : 1.0
#Git            : https://github.com/SaberMage/Alsa-USB
#####################################################################
#Script Name  : install.sh
#Date          : 20210310	(YYYYMMDD)
#Description  : The installation script.
#Usage        : wget -N https://raw.githubusercontent.com/SaberMage/Alsa-USB/main/install.sh
#              : chmod +x install.sh
#              : bash install.sh
#Author       : Reavo End (Brandon Smith)
#####################################################################
#Credits		  : Naprosnia : https://github.com/Naprosnia
#####################################################################

GREEN='\033[0;32m'
LGREEN='\033[1;32m'
RED='\033[0;31m'
LRED='\033[1;31m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m'

clear
echo -e " ${LRED}####################################${NC}"
echo -e " ${LRED}#${NC}  ${GREEN}Installing Alsa-USB${NC}  ${LRED}#${NC}"
echo -e " ${LRED}####################################${NC}\n"

COPY1=("CFG"       "/etc/alsa")
COPY2=("CMD"      "/user/local/sbin")
COPY3=("FDOOR"    "/home/pi/RetroPie/retropiemenu")
COPY4=("MENU"     "/home/pi/Alsa-USB")
COPY5=("OPS"        "/opt/alsa-usb")
COPY6=("SYS"        "/etc/modeprobe.d")
COPY7=("USB"        "/etc/udev/rules.d")
SYM1=("S_CFGG"    "/etc")
SYM2=("S_CFGU"    "/home/pi")
APN1=("A_BOOT"    "/etc")
APN2=("A_FDOOR"   "/home/pi/RetroPie/retropiemenu")
APN3=("A_RETP"    "/opts/retropie/configs/all")

SCRIPTPATH=$(realpath $0)


echo -e " ${LRED}[${NC}${LGREEN} Preparing Installation ${NC}${LRED}]${NC}"
sleep 1

########################
##   Kill Processes   ##
########################
echo -e " ${LRED}-${NC}${WHITE} Killing some processes...${NC}"
killall audacious mpg123 >/dev/null 2>&1
########################
########################

########################
##remove older version##
########################
echo -e " ${LRED}-${NC}${WHITE} Removing older versions...${NC}"
rm -rf $BGMOLD
rm -rf $BGM
rm -rf $AUD
[ -e $RPMENU/Background\ Music\ Settings.sh ] && rm -f $RPMENU/Background\ Music\ Settings.sh
#use sudo because, owner can be root or file created incorrectly for any reason
sudo chmod 777 $RPCONFIGS/runcommand-onstart.sh $RPCONFIGS/runcommand-onend.sh $RPCONFIGS/autostart.sh >/dev/null 2>&1
sed -i "/retropie_bgm_player\/bgm_stop.sh/d" $RPCONFIGS/runcommand-onstart.sh >/dev/null 2>&1
sed -i "/retropie_bgm_player\/bgm_play.sh/d" $RPCONFIGS/runcommand-onend.sh >/dev/null 2>&1
sed -i "/retropie_bgm_player\/bgm_init.sh/d" $RPCONFIGS/autostart.sh >/dev/null 2>&1
########################
########################

#############################
##Packages and Dependencies##
#############################
echo -e "\n ${LRED}[${NC} ${LGREEN}Packages and Dependencies Installation${NC} ${LRED}]${NC}"
sleep 1

echo -e " ${LRED}-${NC}${WHITE} Checking packages and dependencies...${NC}"
sleep 1

packages=("unzip" "mpg123" "audacious" "audacious-plugins")

for package in "${packages[@]}"; do
	if dpkg -s $package >/dev/null 2>&1; then
		echo -e " ${LRED}--${NC}${WHITE} $package : ${NC}${LGREEN}Installed${NC}"
	else
		echo -e " ${LRED}--${NC}${WHITE} $package : ${NC}${LRED}Not Installed${NC}"
		installpackages+=("$package")
	fi
done

if [ ${#installpackages[@]} -gt 0 ]; then

	echo -e " ${LRED}---${NC}${WHITE} Installing missing packages and dependencies...${NC}${ORANGE}\n"
	sleep 1

	sudo apt-get update; sudo apt-get install -y ${installpackages[@]}

fi
echo -e "\n ${NC}${LRED}--${NC}${GREEN} All packages and dependencies are installed.${NC}\n"
sleep 1
########################
########################

########################
## Install BGM Player ##
########################

echo -e " ${LRED}[${NC}${LGREEN} Installing RetroPie BGM Player v2 ${NC}${LRED}]${NC}"
sleep 1

echo -e " ${LRED}-${NC}${WHITE} Change some permissions...${NC}"
sleep 1
sudo chmod -R 777 $RPCONFIGS

echo -e " ${LRED}-${NC}${WHITE} Creating folders...${NC}"
sleep 1
mkdir -p -m 0777 $BGMCONTROLGENERAL $BGMCONTROLPLAY $BGMCONTROLPLAYER $BGMBOTH $BGMEMU $BGMMP3 $BGMCUSTOM $BGMMUSICS $AUD

echo -e " ${LRED}--${NC}${WHITE} Downloading system files...${NC}${ORANGE}\n"
sleep 1

function gitdownloader(){

	files=("$@")
	((last_id=${#files[@]} - 1))
	path=${files[last_id]}
	unset files[last_id]

	for i in "${files[@]}"; do
		wget -N -q --show-progress "https://raw.githubusercontent.com/Naprosnia/RetroPie_BGM_Player/$BGMGITBRANCH$path/$i"
		#chmod a+rwx "$i"
	done
}

cd $BGM
BGMFILES=("bgm_system.sh" "bgm_control.sh" "bgm_settings.ini" "version.sh")
gitdownloader ${BGMFILES[@]} "/RetroPie-BGM-Player"

cd $BGMCONTROL
BGMFILES=("bgm_updater.sh")
gitdownloader ${BGMFILES[@]} "/RetroPie-BGM-Player/bgm_control"

cd $BGMCONTROLGENERAL
BGMFILES=("bgm_general.sh" "bgm_setplayer.sh" "bgm_settoggle.sh" "bgm_setvolume.sh" "bgm_setplayercustom.sh")
gitdownloader ${BGMFILES[@]} "/RetroPie-BGM-Player/bgm_control/general"

cd $BGMCONTROLPLAY
BGMFILES=("bgm_play.sh" "bgm_setdelay.sh" "bgm_setfade.sh" "bgm_setnonstop.sh")
gitdownloader ${BGMFILES[@]} "/RetroPie-BGM-Player/bgm_control/play"

cd $BGMCONTROLPLAYER
BGMFILES=("bgm_player.sh" "bgm_reloadaudio.sh")
gitdownloader ${BGMFILES[@]} "/RetroPie-BGM-Player/bgm_control/player"

cd $RPMENU
BGMFILES=("RetroPie-BGM-Player.sh")
gitdownloader ${BGMFILES[@]} "/RetroPie-BGM-Player"

cd $AUD
BGMFILES=("config" )
gitdownloader ${BGMFILES[@]} "/audconfig"

cd $BGMMUSICS
BGMFILES=("music.zip")
gitdownloader ${BGMFILES[@]} "/music"
unzip -o music.zip  && rm -f music.zip

echo -e "\n ${NC}${LRED}--${NC}${WHITE} Applying permissions...${NC}"
sleep 1
chmod -R a+rwx $BGM $BGMMUSICS
chmod 0444 $AUD/config

echo -e " ${LRED}-${NC}${WHITE} Writing commands...${NC}"
sleep 1

cd $RPCONFIGS
echo -e " ${LRED}--${NC}${WHITE} Writing on runcommand commands...${NC}"
sleep 1
function runcommandsetup(){

	file=$1
	command=$2

	if [ ! -e $file ]; then
			echo -e " ${LRED}---${NC}${WHITE} $file not found, creating...${NC}"
			sleep 1
			touch $file
			sleep 0.5
			chmod a+rwx $file
			sleep 0.5
			echo "$command" > $file
		else
			echo -e " ${LRED}---${NC}${WHITE} $file found, writing...${NC}"
			sleep 1
			#use sudo because, owner can be root or file created incorrectly for any reason
			sudo chmod 777 $file
			sleep 0.5
			sed -i "/bgm_system.sh/d" $file
			[ -s $file ] && sed -i "1i $command" $file || echo "$command" > $file
	fi
}
runcommandsetup "runcommand-onstart.sh" "bash \$HOME/RetroPie-BGM-Player/bgm_system.sh -s"
runcommandsetup "runcommand-onend.sh" "bash \$HOME/RetroPie-BGM-Player/bgm_system.sh -p"
sleep 1
echo -e " ${LRED}--${NC}${WHITE} Writing on autostart script...${NC}"
sleep 1
#use sudo because, owner can be root or file created incorrectly for any reason
sudo chmod 777 autostart.sh
sed -i "/bgm_system.sh/d" autostart.sh
sed -i "1 i bash \$HOME/RetroPie-BGM-Player/bgm_system.sh -i --autostart" autostart.sh
sleep 1

echo -e "\n ${LRED}[${NC}${LGREEN} Installation Finished ${NC}${LRED}]${NC}\n"
sleep 1
########################
########################

########################
##       Restart      ##
########################
if [ "$1" == "--update" ]; then
	(rm -f $SCRIPTPATH; bash $BGMCONTROL/bgm_updater.sh --reboot)
else
	echo -e " ${LRED}[${NC}${LGREEN} Restart System ${NC}${LRED}]${NC}"
	echo -e " ${LRED}-${NC}${WHITE} To finish, we need to reboot.${NC}${ORANGE}\n"
	read -n 1 -s -r -p " Press any key to Restart."
	echo -e "${NC}\n"
	(rm -f $SCRIPTPATH; sudo reboot)
fi
########################
########################
