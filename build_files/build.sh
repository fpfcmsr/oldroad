#!/bin/bash

set -ouex pipefail

#' /opt`, `/usr/local`, `/mnt`, `/root` home, `/media`, + few others are symlinked to /var
# see and example below for installations that need to write to these directories

#install packages for dolphin shortcuts
#brew install jpegoptim optipng pandoc qpdf  xclip foremost rdfind rhash testdisk expect
dnf5 -y install recoll perl-Image-ExifTool # the others can be installed with brew

# useful packages 
dnf5 -y install acpid kde-connect speech-dispatcher android-tools keepassxc gcc make ripgrep fd-find unzip neovim
touch /usr/share/polkit-1/actions/org.keepassxc.KeePassXC.policy.in
echo '<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">
<policyconfig>
  <vendor>KeePassXC Developers</vendor>
  <vendor_url></vendor_url>
  <icon_name>@APP_ICON_NAME@</icon_name>

  <action id="org.keepassxc.KeePassXC.unlockDatabase">
    <description>Quick Unlock for a KeePassXC Database</description>
    <message>Authentication is required to unlock a KeePassXC Database</message>
    <defaults>
      <allow_inactive>no</allow_inactive>
      <allow_active>auth_self</allow_active>
    </defaults>
  </action>
</policyconfig>' >> /usr/share/polkit-1/actions/org.keepassxc.KeePassXC.policy.in

# remove vscode (and realize that vscodium is not it...)
dnf5 -y remove code
#curl --output-dir /etc/yum.repos.d -LO https://repo.vscodium.dev/vscodium.repo
#dnf5 -y install codium

#copr install webapp manager from bazzite
dnf5 -y copr enable bazzite-org/webapp-manager
dnf5 -y install webapp-manager 
dnf5 -y copr disable bazzite-org/webapp-manager

rm /opt
mkdir /opt

rm /root
mkdir /root

#microsoft fonts install
dnf5 -y install mscore-fonts-all xorg-x11-font-utils cabextract fontconfig
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

#get terra repo (repo is already present in universal blue images for now)
#dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
#dnf5 -y config-manager setopt terra.enabled=1
#dnf5 -y install zed
#dnf5 -y config-manager setopt terra.enabled=0
# fix zed execution to zeditor so as to not conflict with zfs - do it twice bc currently theres a commit with the fix that hasn't been merged yet. 
#sed -i 's/Exec=zeditor/Exec=zed/g' /usr/share/applications/dev.zed.Zed.desktop
#sed -i 's/Exec=zed/Exec=zeditor/g' /usr/share/applications/dev.zed.Zed.desktop

#create directory for custom rpm download and install
mkdir /tmp/rpms

# get and download / install bitwarden rpm
URL=$(curl -s https://api.github.com/repos/bitwarden/clients/releases | jq -r 'first(.[] | .assets[]? | select(.browser_download_url | endswith(".rpm")) | .browser_download_url)')
echo "Downloading Bitwarden from $URL"
curl -sL -o /tmp/rpms/bitwarden-latest.rpm "$URL"
#bitwarden policy file
touch /usr/share/polkit-1/actions/com.bitwarden.Bitwarden.policy
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">

<policyconfig>
    <action id="com.bitwarden.Bitwarden.unlock">
      <description>Unlock Bitwarden</description>
      <message>Authenticate to unlock Bitwarden</message>
      <defaults>
        <allow_any>no</allow_any>
        <allow_inactive>no</allow_inactive>
        <allow_active>auth_self</allow_active>
      </defaults>
    </action>
</policyconfig>' > /usr/share/polkit-1/actions/com.bitwarden.Bitwarden.policy

#install all the downloaded rpms
dnf5 install -y /tmp/rpms/*

#ensure things downloaded to /opt and /root are present in final image and clean up symlinks
#mkdir /usr/share/factory/opt
mv /opt /usr/share/factory
ln -s /var/opt /opt
ls -a /usr/share/factory/opt

#mkdir /usr/share/factory/root
mv /root /usr/share/factory
ln -s /var/root /root
ls -a /usr/share/factory/root

# currently not installing these: 

# btrfs assistant
#dnf5 -y install btrfs-assistant

#for phone integration via usb
#dnf5 -y copr enable zeno/scrcpy
#dnf5 -y install scrcpy 
#dnf5 -y copr disable zeno/scrcpy

#copr install python validity for fingerprint reader
#dnf5 -y copr enable sneexy/python-validity
#dnf5 -y install open-fprintd fprintd-clients fprintd-clients-pam python3-validity
#dnf5 -y copr disable sneexy/python-validity

#handheld daemon
#sudo dnf5 -y copr enable hhd-dev/hhd
#sudo dnf5 -y install hhd adjustor hhd-ui
#sudo dnf5 -y copr disable hhd-dev/hhd

#install specific brother printers (no longer needed)
#curl --retry 3 -Lo /tmp/rpms/mfcl2710dwpdrv-4.0.0-1.i386.rpm "https://download.brother.com/welcome/dlf103525/mfcl2710dwpdrv-4.0.0-1.i386.rpm"
#curl --retry 3 -Lo /tmp/rpms/brscan4-0.4.11-1.x86_64.rpm "https://download.brother.com/welcome/dlf105203/brscan4-0.4.11-1.x86_64.rpm"
#curl --retry 3 -Lo /tmp/rpms/brscan-skey-0.3.2-0.x86_64.rpm "https://download.brother.com/welcome/dlf006650/brscan-skey-0.3.2-0.x86_64.rpm"
#curl --retry 3 -Lo /tmp/rpms/brother-udev-rule-type1-1.0.2-0.noarch.rpm "https://download.brother.com/welcome/dlf103900/brother-udev-rule-type1-1.0.2-0.noarch.rpm"
#curl --retry 3 -Lo /tmp/rpms/brmfcfaxdrv-2.0.2-1.x86_64.rpm "https://download.brother.com/welcome/dlf105190/brmfcfaxdrv-2.0.2-1.x86_64.rpm"
