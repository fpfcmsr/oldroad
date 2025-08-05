#!/bin/bash

set -ouex pipefail

#' /opt`, `/usr/local`, `/mnt`, `/root` home, `/media`, + few others are symlinked to /var
# see and example below for installations that need to write to these directories

#install packages for dolphin shortcuts
#dnf5 -y install jpegoptim optipng pandoc qpdf recoll  xclip foremost perl-Image-ExifTool rdfind rhash testdisk expect
dnf5 -y install recoll perl-Image-ExifTool # the others can be installed with brew

#for acpi event stuff, good for monitoring multimonitor events
dnf5 -y install acpid
# btrfs assistant
#dnf5 -y install btrfs-assistant

#for phone integration via usb
#dnf5 -y copr enable zeno/scrcpy
#dnf5 -y install scrcpy 
#dnf5 -y copr disable zeno/scrcpy

#copr install webapp manager from bazzite
dnf5 -y copr enable bazzite-org/webapp-manager
dnf5 -y install webapp-manager 
dnf5 -y copr disable bazzite-org/webapp-manager

rm /opt
mkdir /opt

rm /root
mkdir /root

#copr install python validity for fingerprint reader
#dnf5 -y copr enable sneexy/python-validity
#dnf5 -y install open-fprintd fprintd-clients fprintd-clients-pam python3-validity
#dnf5 -y copr disable sneexy/python-validity

#handheld daemon
#sudo dnf5 -y copr enable hhd-dev/hhd
#sudo dnf5 -y install hhd adjustor hhd-ui
#sudo dnf5 -y copr disable hhd-dev/hhd

#install specific brother printers
mkdir /tmp/rpms
#curl --retry 3 -Lo /tmp/rpms/mfcl2710dwpdrv-4.0.0-1.i386.rpm "https://download.brother.com/welcome/dlf103525/mfcl2710dwpdrv-4.0.0-1.i386.rpm"
#curl --retry 3 -Lo /tmp/rpms/brscan4-0.4.11-1.x86_64.rpm "https://download.brother.com/welcome/dlf105203/brscan4-0.4.11-1.x86_64.rpm"
#curl --retry 3 -Lo /tmp/rpms/brscan-skey-0.3.2-0.x86_64.rpm "https://download.brother.com/welcome/dlf006650/brscan-skey-0.3.2-0.x86_64.rpm"
#curl --retry 3 -Lo /tmp/rpms/brother-udev-rule-type1-1.0.2-0.noarch.rpm "https://download.brother.com/welcome/dlf103900/brother-udev-rule-type1-1.0.2-0.noarch.rpm"
#curl --retry 3 -Lo /tmp/rpms/brmfcfaxdrv-2.0.2-1.x86_64.rpm "https://download.brother.com/welcome/dlf105190/brmfcfaxdrv-2.0.2-1.x86_64.rpm"

# get and download / install bitwarden rpm
URL=$(curl -s https://api.github.com/repos/bitwarden/clients/releases | jq -r 'first(.[] | .assets[]? | select(.browser_download_url | endswith(".rpm")) | .browser_download_url)')
echo "Downloading Bitwarden from $URL"
curl -sL -o /tmp/rpms/bitwarden-latest.rpm "$URL"

#install all the downloaded rpms
dnf5 install -y /tmp/rpms/*


#microsoft fonts install
#dnf5 -y install mscore-fonts-all xorg-x11-font-utils cabextract fontconfig
#rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

mv /opt /usr/share/factory
ln -s /var/opt /opt
ls -a /usr/share/factory/opt/

mv /root /usr/share/factory
ln -s /var/root /root
ls -a /usr/share/factory/root/

