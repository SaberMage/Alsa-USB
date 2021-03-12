#! /bin/bash
#Intended only for us with POSIX ., i.e. ". ./write-scard.sh"

AU_DIR="/opt/alsa-usb"
AU_VARS="$AU_DIR/cur-scard.sh"
#Write environment vars to cur-scard.sh
printf "export USB_EXIST=${USB_EXIST}\nexport SOUND_CARD=${SOUND_CARD}\nexport CARD_EVENT=${CARD_EVENT}\nexport AUTO_DISABLE=${AU_DIR}/auto-switch.disable\nexport GAME_DISABLE=${AU_DIR}/game-on.disable\nexport WRITE_VARS=${AU_DIR}/write-scard.sh\n" | sudo tee "${AU_VARS}" > /dev/null
