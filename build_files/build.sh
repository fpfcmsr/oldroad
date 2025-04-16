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
dnf5 install -y scrcpy 
dnf5 -y copr disable zeno/scrcpy

#copr install webapp manager from bazzite
dnf5 -y copr enable bazzite-org/webapp-manager
dnf5 -y install webapp-manager 
dnf5 -y copr disable bazzite-org/webapp-manager

#copr install kde-kup for backups
#dnf5 -y copr enable justinz/kup
#dnf5 install kde-kup
#dnf5 -y copr disable justinz/kup

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

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

# install dolphin helper scripts
cd /tmp
git clone https://github.com/cfgnunes/nautilus-scripts.git
cd nautilus-scripts
rm /tmp/nautilus-scripts/install.sh
cp /ctx/install.sh /tmp/nautilus-scripts/install.sh
chmod +x install.sh

rm /root
mkdir /root
bash install.sh
mv /root /usr/share/factory
ln -s /var/root /root

#### Example for enabling a System Unit File

systemctl enable supergfxd.service 
systemctl disable nvidia-persistenced
systemctl mask nvidia-persistenced

# edit gpu switching config to enable seamless hotplug
touch /etc/supergfxd.conf
echo '{
“mode”: “Hybrid”,
“vfio_enable”: true,
“vfio_save”: false,
“always_reboot”: false,
“no_logind”: true,
“logout_timeout_s”: 60,
“hotplug_type”: “Asus”
}' >> /etc/supergfxd.conf
