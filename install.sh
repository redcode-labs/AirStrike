#!/bin/bash
echo "Installing AirStrike..."

cp watcher.sh /usr/bin/
ispresent(){
 	if command -v "$1" >/dev/null;then
		return 0
	else
		return 1
	fi
}

if ispresent apt;then
  apt-get -y update &> /dev/null
  apt-get -y install hashcat &> /dev/null
  apt-get -y install hashcat-utils &> /dev/null
  apt-get -y install aircrack-ng &> /dev/null
  apt-get -y install entr &> /dev/null
  apt-get -y install hcxtools &> /dev/null
fi

if ispresent pacman;then
  pacman -Syu
  pacman -S hashcat &> /dev/null
  pacman -S hashcat-utils &> /dev/null
  pacman -S aircrack-ng &> /dev/null
  pacman -S entr &> /dev/null
  pacman -S hcxtools &> /dev/null
fi

if ispresent emerge;then
  emaint -a sync &> /dev/null
  emerge-webrsync &> /dev/null
  eix-sync &> /dev/null
  emerge -a app-crypt/hashcat &> /dev/null
  emerge -a app-crypt/hashcat-utils
  emerge -a net-wireless/aircrack-ng &> /dev/null
  emerge -a app-admin/entr &> /dev/null
fi

if ispresent xbps-install;then
  xbps-install -Syu &> /dev/null
  xbps-install -y hashcat &> /dev/null
  xbps-install -y hashcat-utils &> /dev/null
  xbps-install -y aircrack-ng &> /dev/null
  xbps-install -y entr &> /dev/null
  xbps-install -y hcxtools &> /dev/null
fi
