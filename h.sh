#!/bin/bash -e
#
# system stuff first, user stuff next...
# less likely to be modified items first, more likely to be modified items next...

#
# execute command with external shell; retry if unsuccessful (up to 5 times total)
#
try()
{
	local I=5
	
	while true ; do
		$SHELL -c "$1" && return 0
		I=$(($I-1))
		[ $I = 0 ] && break
		echo ==== WARNING: "$1" failed, retrying in 5 seconds...
		sleep 5
		echo ==== Retrying now, this may take a while...
	done
	return 1
}

trap "echo Premature exit." ERR

[ -z "$FAHINSTALL_BRANCH" ] && FAHINSTALL_BRANCH=released

touch ~/.bash_history
touch ~/.lesshst
export SWAPDEV=$(tail -n +2 < /proc/swaps | head -n 1 | cut -f 1 -d  \ )
sudo swapoff -a

try "sudo apt-get clean"
sudo mkdir /dev/shm/archives/
sudo mount --bind /dev/shm/archives/ /var/cache/apt/archives/
sudo mkdir /var/cache/apt/archives/partial
sudo touch /var/cache/apt/archives/lock

sudo dpkg -P fonts-opensymbol gir1.2-gst-plugins-base-0.10 gir1.2-gstreamer-0.10 gir1.2-rb-3.0 gir1.2-totem-1.0 gir1.2-totem-plparser-1.0 gir1.2-ubuntuoneui-3.0 hyphen-en-us libexttextcat-data libgpod-common libmtp-common libmtp-runtime libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-help-en-us libreoffice-impress libreoffice-math libreoffice-style-human libreoffice-style-tango libreoffice-writer librhythmbox-core5 libsyncdaemon-1.0-1 libtotem0 libubuntuoneui-3.0-1 media-player-info mythes-en-us openoffice.org-hyphenation protobuf-compiler python-configglue python-dirspec python-mako python-markupsafe python-protobuf python-pyinotify python-twisted-names python-ubuntuone-client python-ubuntuone-control-panel python-ubuntuone-storageprotocol python-uno rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-magnatune rhythmbox-plugin-zeitgeist rhythmbox-plugins rhythmbox-ubuntuone shotwell thunderbird thunderbird-globalmenu thunderbird-gnome-support thunderbird-locale-en thunderbird-locale-en-us totem totem-common totem-mozilla totem-plugins transmission-common transmission-gtk ubuntuone-client ubuntuone-client-gnome ubuntuone-control-panel ubuntuone-couch ubuntuone-installer unity-scope-musicstores uno-libs3 ure libexttextcat0 libmtp9 libcmis-0.2-0 libdiscid0 libdmapsharing-3.0-2 libevent-2.0-5 libexiv2-11 libgexiv2-1 libgpod4 libhyphen0 liblircclient0 libmhash2 libmusicbrainz3-6 libmythes-1.2-0 libneon27-gnutls libprotoc7 libraptor2-0 librasqal3 libraw5 librdf0 libwpd-0.9-9 libwpg-0.2-2 libwps-0.2-2 libyajl1 xfonts-mathml popularity-contest ubuntu-standard

[ -f /etc/init/avahi-daemon.conf ] && sudo patch -p0 < avahi-daemon.diff
[ -f /etc/init/bluetooth.conf ] && sudo patch -p0 < bluetooth.diff
[ -f /etc/init/cups.conf ] && sudo patch -p0 < cups.diff
[ -f /etc/init/lightdm.conf ] && sudo patch -p0 < lightdm.diff
[ -f /etc/init/whoopsie.conf ] && sudo patch -p0 < whoopsie.diff

# install [H] kernel
sudo dpkg -P	linux-image-generic-lts-quantal  linux-generic-lts-quantal \
		linux-headers-generic-lts-quantal \
		linux-image-generic linux-generic \
		linux-headers-generic \
		'linux-image-[0-9]*' 'linux-image-extra-[0-9]*' \
		'linux-headers-[0-9]*'
sudo dpkg -i linux-*.deb
rm linux-*.deb

sudo cp resize-rootfs /usr/bin/
sudo touch /.h-resizepartition

sudo cp update-uuids /usr/bin/
sudo -E update-uuids 66666666-6666-6666-6666-666666666666 99999999-9999-9999-9999-999999999999
sudo touch /.h-update-uuids

sudo find /etc/ssl/certs -maxdepth 1 -not -type d \( -lname ssl-cert-snakeoil.pem -or -name ssl-cert-snakeoil.pem \) -exec rm {} \;
sudo rm /etc/ssl/private/ssl-cert-snakeoil.key
sudo touch /.h-reconfigure-ssl-cert

sudo touch /.h-configure-openssh

sudo cp hostname-persistent /usr/bin/
sudo cp horde-startup.conf /etc/init/
sudo ln -s /lib/init/upstart-job /etc/init.d/horde-startup

try "sudo apt-get -y install ncurses-dev g++"
try "sudo apt-get clean"
if [ -d /usr/share/backgrounds ]; then
  sudo cp h.png /usr/share/backgrounds/
  sudo touch -d '2013-06-03 06:05' /usr/share/backgrounds/h.png
fi
if [ -f /usr/share/glib-2.0/schemas/gschemas.compiled ]; then
  sudo cp 10_gsettings-desktop-schemas.gschema.override /usr/share/glib-2.0/schemas/10_gsettings-desktop-schemas.gschema.override
  sudo cp com.canonical.unity-greeter.gschema.xml /usr/share/glib-2.0/schemas/com.canonical.unity-greeter.gschema.xml
  sudo cp org.gnome.desktop.screensaver.gschema.xml /usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.xml
  cd /usr/share/glib-2.0/schemas/
  sudo glib-compile-schemas .
  cd -
fi
if [ -d /usr/share/gconf/defaults ]; then
  sudo cp 10_libgnome2-common /usr/share/gconf/defaults/10_libgnome2-common
fi
if [ -d /usr/share/gnome-background-properties ]; then
  sudo cp ubuntu-wallpapers.xml /usr/share/gnome-background-properties/ubuntu-wallpapers.xml
fi
if [ -f /var/lib/gconf/debian.defaults/%gconf-tree.xml ]; then
  cp /var/lib/gconf/debian.defaults/%gconf-tree.xml /dev/shm/%gconf-tree.xml-backup
  cat /var/lib/gconf/debian.defaults/%gconf-tree.xml  | awk '/entry name/ { W=$2 ; T=$3 ; print ; next } ; { if (W == "name=\"primary_color\"") { print "\t\t\t\t\t<stringvalue>#000000</stringvalue>" ; print "\t\t\t\t</entry>" ; print "\t\t\t\t<entry name=\"secondary_color\" " T " type=\"string\">" ; print "\t\t\t\t\t<stringvalue>#000000</stringvalue>" ; W="" ; next } ; if (W == "name=\"picture_options\"") { print "\t\t\t\t\t<stringvalue>centered</stringvalue>" ; W="" ; next } ; if (W == "name=\"picture_filename\"") { print "\t\t\t\t\t<stringvalue>/usr/share/backgrounds/h.png</stringvalue>" ; W="" ; next } ; print }' > /dev/shm/%gconf-tree.xml
  sudo dd bs=4k if=/dev/shm/%gconf-tree.xml of=/var/lib/gconf/debian.defaults/%gconf-tree.xml
fi

mkdir tpc
tar -C tpc -xzf tpc-*-src.tar.gz
cd tpc/*/
make
sudo make install
cd -

mkdir i7z
tar -C i7z -xzf i7z-*.tar.gz
cd i7z/*/
make
sudo make install
cd -

mkdir ocng-utils
tar -C ocng-utils -xzf ocng-utils-*.tar.gz
cd ocng-utils/*/
make
sudo make install
cd -


if [ -x /usr/bin/gnome-terminal ]; then
  try "sudo apt-get -y install dconf-tools"
  try "sudo apt-get clean"
  dconf write /desktop/unity/launcher/favorites "['nautilus-home.desktop','firefox.desktop','ubuntu-software-center.desktop','gnome-control-center.desktop','gnome-terminal.desktop']"
  cp %gconf.xml ~/.gconf/apps/gnome-terminal/profiles/Default/
fi

if [ -d ~/Desktop ]; then
  wget https://raw.github.com/team33/hfminstall/$FAHINSTALL_BRANCH/hfminstall
  chmod +x hfminstall
  sudo ./hfminstall
  try "sudo apt-get clean"
  mkdir ~/.config/HFM/
  cp hfm.hfmx ~/.config/HFM/HFM.hfmx

  cp DOUBLE*ME ~/Desktop/

  gvfs-set-attribute ~/Desktop/HFM.desktop metadata::nautilus-icon-position 64,10
  gvfs-set-attribute ~/Desktop/DOUBLE-CLICK\ ME metadata::nautilus-icon-position 424,177
  sed -r -i 's/^(nautilus-icon-view-keep-aligned)=.*$/\1=false/' ~/.config/nautilus/desktop-metadata
fi

cd /usr/bin
sudo wget https://raw.github.com/team33/fahinstall/$FAHINSTALL_BRANCH/fahinstall
sudo chmod +x fahinstall
cd -

sudo fahinstall -F -S -t /dev/shm -b $FAHINSTALL_BRANCH
try "sudo apt-get clean"

rm -f ~/.xsession-errors
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
sudo rm -f /var/log/auth.log
sudo rm -f /var/log/boot.log
sudo rm -f /var/log/ConsoleKit/history
sudo rm -f /var/log/cups/*
sudo rm -f /var/log/dmesg*
sudo rm -f /var/log/kern.log
sudo rm -f /var/log/lightdm/*
sudo rm -f /var/log/pm-powersave.log
sudo rm -f /var/log/samba/log.smbd
sudo rm -f /var/log/samba/log.nmbd
sudo rm -f /var/log/syslog
sudo rm -f /var/log/udev
sudo rm -f /var/log/upstart/*
sudo rm -f /var/log/Xorg.0.log*

echo 9-pre | sudo dd of=/etc/h-ubuntu

echo
echo Success!
echo
echo Now, execute \'ulimit -n 0\', close terminal and power-off the machine,
echo then zip the image and you\'re done!

#ulimit -n 0
# close terminal
# power off (from the panel)
