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

CFG=        "/etc/alsa"
CMD=        "/user/local/sbin"
FDOOR=      "/home/pi/RetroPie/retropiemenu"
MENU=       "/home/pi/Alsa-USB"
OPS=        "/opt/alsa-usb"
SYS=        "/etc/modeprobe.d"
USB=        "/etc/udev/rules.d"
S_CFGG=    "/etc"
S_CFGU=    "/home/pi"
A_BOOT=    "/etc"
A_FDOOR=   "/home/pi/RetroPie/retropiemenu"
A_RETP=    "/opts/retropie/configs/all"

INSTALLPATH="/home/pi/au-install"
SCRIPTPATH=$(realpath $0)


echo -e " ${LRED}[${NC}${LGREEN} Preparing Installation ${NC}${LRED}]${NC}"
sleep 1

########################
##   Kill Processes   ##
########################
# echo -e " ${LRED}-${NC}${WHITE} Killing some processes...${NC}"
# killall audacious mpg123 >/dev/null 2>&1
########################
########################

########################
##remove older version##
########################
echo -e " ${LRED}-${NC}${WHITE} Removing older versions...${NC}"
# rm -rf $BGMOLD
# [ -e $RPMENU/Background\ Music\ Settings.sh ] && rm -f $RPMENU/Background\ Music\ Settings.sh
# use sudo because, owner can be root or file created incorrectly for any reason
# sed -i "/retropie_bgm_player\/bgm_stop.sh/d" $RPCONFIGS/runcommand-onstart.sh >/dev/null 2>&1
# sed -i "/retropie_bgm_player\/bgm_play.sh/d" $RPCONFIGS/runcommand-onend.sh >/dev/null 2>&1
# sed -i "/retropie_bgm_player\/bgm_init.sh/d" $RPCONFIGS/autostart.sh >/dev/null 2>&1
########################
########################

#############################
##Packages and Dependencies##
#############################
# echo -e "\n ${LRED}[${NC} ${LGREEN}Packages and Dependencies Installation${NC} ${LRED}]${NC}"
# sleep 1

# echo -e " ${LRED}-${NC}${WHITE} Checking packages and dependencies...${NC}"
# sleep 1

# packages=("unzip" "mpg123" "audacious" "audacious-plugins")

# for package in "${packages[@]}"; do
# 	if dpkg -s $package >/dev/null 2>&1; then
# 		echo -e " ${LRED}--${NC}${WHITE} $package : ${NC}${LGREEN}Installed${NC}"
# 	else
# 		echo -e " ${LRED}--${NC}${WHITE} $package : ${NC}${LRED}Not Installed${NC}"
# 		installpackages+=("$package")
# 	fi
# done

# if [ ${#installpackages[@]} -gt 0 ]; then
#
# 	echo -e " ${LRED}---${NC}${WHITE} Installing missing packages and dependencies...${NC}${ORANGE}\n"
# 	sleep 1
#
# 	sudo apt-get update; sudo apt-get install -y ${installpackages[@]}
#
# fi
# echo -e "\n ${NC}${LRED}--${NC}${GREEN} All packages and dependencies are installed.${NC}\n"
# sleep 1
########################
########################

########################
## Install Alsa-USB ##
########################

echo -e " ${LRED}[${NC}${LGREEN} Installing Alsa-USB v. 1.0 ${NC}${LRED}]${NC}"
sleep 1

echo -e " ${LRED}-${NC}${WHITE} Change some permissions...${NC}"
sleep 1
# sudo chmod 777 ${A_RETP}/runcommand-onstart.sh ${A_RETP}/runcommand-onend.sh ${A_RETP}/autostart.sh >/dev/null 2>&1
sudo chmod -R 777 ${A_RETP}

echo -e " ${LRED}-${NC}${WHITE} Creating folders...${NC}"
sleep 1
mkdir -p -m 0777 ${MENU} ${OPS}

echo -e " ${LRED}--${NC}${WHITE} Downloading system files...${NC}${ORANGE}\n"
sleep 1

sudo mkdir ~/au-install
cd ~/au-install
sudo git clone --depth 1 "https://github.com/SaberMage/Alsa-USB" &> /dev/null
sudo rm -rf ./Alsa-USB/.git

echo -e "\n ${NC}${LRED}--${NC}${WHITE} Applying permissions...${NC}"
sleep 1
sudo chmod 777 -R ./Alsa-USB
cd ./Alsa-USB

echo -e " ${LRED}--${NC}${WHITE} Distributing and modifying core files...${NC}"
sleep 1
function installFolder() {
  local folder=$1
  local prefix=${folder:0:2} #First two chars of folder name
  local target=$(eval echo '$'$folder) #Destination folder for files/actions

  case $prefix in
    S_) #Symlink
      ;;
    A_) #Append/insert
      ;;
    *) #Copy files
      ;;
  esac
}
#Iterate over folders in ./nexus

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
# if [ "$1" == "--update" ]; then
# 	(rm -f $SCRIPTPATH; bash $BGMCONTROL/bgm_updater.sh --reboot)
# else
	echo -e " ${LRED}[${NC}${LGREEN} Restart System ${NC}${LRED}]${NC}"
	echo -e " ${LRED}-${NC}${WHITE} To finish, we need to reboot.${NC}${ORANGE}\n"
	read -n 1 -s -r -p " Press any key to Restart."
	echo -e "${NC}\n"
	rm -rfd $INSTALL_PATH && rm -f $SCRIPTPATH && sudo reboot
# fi
########################
########################
