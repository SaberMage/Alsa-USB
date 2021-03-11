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

CFG="/etc/alsa"
CMD="/usr/local/sbin"
FDOOR="/home/pi/RetroPie/retropiemenu"
MENU="/home/pi/Alsa-USB"
OPS="/opt/alsa-usb"
SYS="/etc/modprobe.d"
USB="/etc/udev/rules.d"
ZS_CFGG="/etc"
ZS_CFGU="/home/pi"
ZA_BOOT="/etc"
ZA_FDOOR="/home/pi/RetroPie/retropiemenu"
ZA_RETP="/opt/retropie/configs/all"

SLEEPTIME=1
INSTALLPATH="/home/pi/au-install"
NEXUSPATH="$INSTALLPATH/Alsa-USB/nexus"
SCRIPTPATH=$(realpath $0)
copyprefix="/home/pi/test" #DEBUG - Extracted files will use this as their root dir, for testing

NEEDMADE=($INSTALLPATH $MENU $OPS)
declare -a NEXUSDIRS #Will become an array of all directories in the nexus


echo -e " ${LRED}[${NC}${LGREEN} Preparing Installation ${NC}${LRED}]${NC}"
sleep $SLEEPTIME

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
# echo -e " ${LRED}-${NC}${WHITE} Removing older versions...${NC}"
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
# sleep $SLEEPTIME

# echo -e " ${LRED}-${NC}${WHITE} Checking packages and dependencies...${NC}"
# sleep $SLEEPTIME

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
# 	sleep $SLEEPTIME
#
# 	sudo apt-get update; sudo apt-get install -y ${installpackages[@]}
#
# fi
# echo -e "\n ${NC}${LRED}--${NC}${GREEN} All packages and dependencies are installed.${NC}\n"
# sleep $SLEEPTIME
########################
########################

########################
## Install Alsa-USB ##
########################

echo -e " ${LRED}[${NC}${LGREEN} Installing Alsa-USB v. 1.0 ${NC}${LRED}]${NC}"
sleep $SLEEPTIME

echo -e " ${LRED}-${NC}${WHITE} Change some permissions...${NC}"
sleep $SLEEPTIME
# sudo chmod 777 ${ZA_RETP}/runcommand-onstart.sh ${ZA_RETP}/runcommand-onend.sh ${ZA_RETP}/autostart.sh >/dev/null 2>&1
sudo chmod -R 777 ${ZA_RETP}

echo -e " ${LRED}-${NC}${WHITE} Creating folders...${NC}"
sleep $SLEEPTIME
sudo mkdir -p -m 777 ${NEEDMADE[*]} &> /dev/null

echo -e " ${LRED}--${NC}${WHITE} Downloading system files...${NC}${ORANGE}\n"
sleep $SLEEPTIME

sudo mkdir -p ~/au-install &> /dev/null
cd ~/au-install
sudo git clone --depth 1 "https://github.com/SaberMage/Alsa-USB" &> /dev/null
sudo rm -rf ./Alsa-USB/.git

echo -e "\n ${NC}${LRED}--${NC}${WHITE} Applying permissions...${NC}"
sleep $SLEEPTIME
sudo chmod 777 -R ./Alsa-USB
cd ./Alsa-USB/nexus
#Get & store all /nexus subdirectory names
i=0; for d in */; do NEXUSDIRS[i++]="${d%/}"; done

echo -e " ${LRED}--${NC}${WHITE} Distributing and modifying core files...${NC}"
sleep $SLEEPTIME
function installfolder() {
  local dir=$1
  local prefix=${dir:1:2} #Chars 2 and 3 of folder name
  local target=$(eval echo '$'$dir) #Destination folder for files/actions
  local fulltarget="${copyprefix}$target"

  cd "$NEXUSPATH/$dir"

  case $prefix in
    S_) #Symlink
      #Note: Does not permit target subdirectories. Each unique target dir will need its own nexus dir
      #Filename like ",home,pi,source-dir,source.txt,,linked.txt" translates to:
      #Symlink "/home/pi/source-dir/source.txt" to "$fulltarget/linked.txt"
      sudo rm -f __* #Remove the info file; not used for these folders
      local files=(*) #Create array of remaining files
      for fname in ${files[@]}; do
        #Derive source filepath by parsing the nexus filename
        local src=$(echo "$fname" | sed 's/,,.*$//' | sed 's/,/\//g')
        #Derive output filename by parsing the nexus filename
        local dest="${fulltarget}/$(echo "$fname" | sed 's/^.*,,//')"
        echo -e " ${LGREEN}> Symlinking ${BLUE}$src ${LGREEN}to ${ORANGE}$dest${NC}"
        sudo mkdir -m 777 -p $fulltarget #Ensure target directory exists
        sudo cp -sf $src $dest
      done
      # readarray -td '?' a <<<$(awk '{ gsub(/,,/,"?"); print; }' <<<"$fname") #Was fun but we don't need it!
      ;;
    A_) #Append/insert
      . __* #Source the installer rules for performing the append/insert; includes REFERENCE, OFFSET, FALLBACK
      sudo rm -f __*
      #Determine command for sed
      local sedcmd
      [ $OFFSET == 'before' ] && sedcmd='e cat' || sedcmd='r'
      local files=(*) #Create array of remaining files
      for fname in ${files[@]}; do
        echo -e " ${RED}###APPEND: $fname from $dir${NC}" #DEBUG
        local fpath="$fulltarget/$fname"
        echo -e " ${LGREEN}> Modifying files in ${ORANGE}$fulltarget${NC}"
        sudo mkdir -m 777 -p $fulltarget #Ensure target directory exists
        sudo chmod 777 $fulltarget
        [ ! -e $fpath ] && touch $fpath #Ensure target file exists
        if [ ! -z "$(sed -n "\\|$REFERENCE|p" $fpath)" ]; then #Reference line is matched
          #local append=$(cat $fname)
          sudo sed -i'.au.bak' -e "\\|$REFERENCE|$sedcmd $fname" "$fpath"
        else #Ref string unmatched; go with the fallback directive
          case $FALLBACK in
            prepend)
              if [ -z "$(cat $fpath)" ]; then cat "$fname" > "$fpath" #File empty; simply output to it
              else
                sudo sed -i'.au.bak' -e "1e cat $fname" "$fpath" #| as delimiter because $append often contains /
              fi
              ;;
            append)
              sudo cp "$fpath" "$fpath.au.bak"
              echo "$append" >> "$fpath"
              ;;
            overwrite)
              sudo cp "$fpath" "$fpath.au.bak"
              echo "$append" > "$fpath"
              ;;
            skip)
              echo -e " ${LGREEN}> No match for ${BLUE}\$REFERENCE ${LGREEN}in ${ORANGE}${fulltarget}${LGREEN}; skipped write!${NC}"
              sleep 3
              ;;
          esac
        fi
      done
      ;;
    *) #Copy files
      #Copies all files recursively (incl. subdirs) to $fulltarget/
      sudo rm -f __* #Remove the info file; not used for these folders
      echo -e " ${LGREEN}> Copying files to ${ORANGE}$fulltarget${NC}"
      sudo mkdir -m 777 -p $fulltarget #Ensure target directory exists
      sudo cp -rf -t $fulltarget ./*
      ;;
  esac
}
#Iterate over folders in ./nexus, perform the proper installation(s) for each
for dir in "${NEXUSDIRS[@]}"; do installfolder $dir; echo i++ &> /dev/null; done

echo -e "\n ${LRED}[${NC}${LGREEN} Installation Finished ${NC}${LRED}]${NC}\n"
sleep $SLEEPTIME
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
	sudo rm -rfd $INSTALLPATH && sudo rm -f $SCRIPTPATH #&& sudo reboot
# fi
########################
########################
