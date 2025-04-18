#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos

#install packages for dolphin shortcuts
dnf5 install -y jpegoptim optipng pandoc qpdf recoll  xclip expect

#microsoft fonts install
dnf5 install -y mscore-fonts-all 

#for phone integration via usb
dnf5 -y copr enable zeno/scrcpy
dnf5 -y install scrcpy 
dnf5 -y copr disable zeno/scrcpy

#copr install webapp manager from bazzite
dnf5 -y copr enable bazzite-org/webapp-manager
dnf5 -y install webapp-manager 
dnf5 -y copr disable bazzite-org/webapp-manager

#copr install python validity for fingerprint reader
dnf5 -y copr enable sneexy/python-validity
dnf5 -y install open-fprintd fprintd-clients fprintd-clients-pam python3-validity
dnf5 -y copr disable sneexy/python-validity

#install specific brother printers
rm /opt
mkdir /opt
mkdir /tmp/rpms
curl --retry 3 -Lo /tmp/rpms/mfcl2710dwpdrv-4.0.0-1.i386.rpm "https://download.brother.com/welcome/dlf103525/mfcl2710dwpdrv-4.0.0-1.i386.rpm"
curl --retry 3 -Lo /tmp/rpms/brscan4-0.4.11-1.x86_64.rpm "https://download.brother.com/welcome/dlf105203/brscan4-0.4.11-1.x86_64.rpm"
curl --retry 3 -Lo /tmp/rpms/brscan-skey-0.3.2-0.x86_64.rpm "https://download.brother.com/welcome/dlf006650/brscan-skey-0.3.2-0.x86_64.rpm"
curl --retry 3 -Lo /tmp/rpms/brother-udev-rule-type1-1.0.2-0.noarch.rpm "https://download.brother.com/welcome/dlf103900/brother-udev-rule-type1-1.0.2-0.noarch.rpm"
curl --retry 3 -Lo /tmp/rpms/brmfcfaxdrv-2.0.2-1.x86_64.rpm "https://download.brother.com/welcome/dlf105190/brmfcfaxdrv-2.0.2-1.x86_64.rpm"
dnf5 install -y /tmp/rpms/*
mv /opt /usr/share/factory
ln -s /var/opt /opt

#### Example for enabling a System Unit File

systemctl enable supergfxd.service 
systemctl disable nvidia-persistenced
systemctl mask nvidia-persistenced
systemctl enable open-fprintd-resume.service open-fprintd-suspend.service open-fprintd.service python3-validity.service
