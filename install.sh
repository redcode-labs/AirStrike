#!/bin/bash
echo "Installing AirStrike..."

cp watcher.sh /usr/bin/

is_apt=$(which apt)
not_found="not"
echo ${is_apt} | grep --quiet "${not_found}"
if [ $? = 1 ]
then
  apt-get -y update &> /dev/null
  apt-get -y install hashcat &> /dev/null
  apt-get -y install hashcat-utils &> /dev/null
  apt-get -y install aircrack-ng &> /dev/null
  apt-get -y install entr &> /dev/null
  apt-get -y install hcxtools &> /dev/null
fi

is_pacman=$(which pacman)
not_found="not"
echo ${is_pacman} | grep --quiet "${not_found}"
if [ $? = 1 ]
then
  pacman -Syu
  pacman -S hashcat &> /dev/null
  pacman -S hashcat-utils &> /dev/null
  pacman -S aircrack-ng &> /dev/null
  pacman -S entr &> /dev/null
  pacman -S hcxtools &> /dev/null
fi

is_emerge=$(which emerge)
not_found="not"
echo ${is_emerge} | grep --quiet "${not_found}"
if [ $? = 1]
then
  emaint -a sync &> /dev/null
  emerge-webrsync &> /dev/null
  eix-sync &> /dev/null
  emerge -a app-crypt/hashcat &> /dev/null
  emerge -a app-crypt/hashcat-utils
  emerge -a net-wireless/aircrack-ng &> /dev/null
  emerge -a app-admin/entr &> /dev/null
fi

is_xbps=$(which xbps)
not_found="not"
echo ${is_xbps} | grep --quiet "${not_found}"
if [ $? = 1 ]
then
  xbps-install -Su &> /dev/null
  xbps-install hashcat &> /dev/null
  xbps-install hashcat-utils &> /dev/null
  xbps-install aircrack-ng &> /dev/null
  xbps-install entr &> /dev/null
fi
