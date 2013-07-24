#!/bin/bash -e
#
# system stuff first, user stuff next...
# less likely to be modified items first, more likely to be modified items next...

trap "echo Premature exit." ERR

FAHINSTALL_BRANCH=released

touch ~/.bash_history
sudo swapoff -a

sudo apt-get clean
sudo mkdir /dev/shm/archives/
sudo mount --bind /dev/shm/archives/ /var/cache/apt/archives/
sudo mkdir /var/cache/apt/archives/partial
sudo touch /var/cache/apt/archives/lock

sudo dpkg -P fonts-opensymbol gir1.2-gst-plugins-base-0.10 gir1.2-gstreamer-0.10 gir1.2-rb-3.0 gir1.2-totem-1.0 gir1.2-totem-plparser-1.0 gir1.2-ubuntuoneui-3.0 hyphen-en-us libexttextcat-data libgpod-common libmtp-common libmtp-runtime libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-help-en-us libreoffice-impress libreoffice-math libreoffice-style-human libreoffice-style-tango libreoffice-writer librhythmbox-core5 libsyncdaemon-1.0-1 libtotem0 libubuntuoneui-3.0-1 media-player-info mythes-en-us openoffice.org-hyphenation protobuf-compiler python-configglue python-dirspec python-mako python-markupsafe python-protobuf python-pyinotify python-twisted-names python-ubuntuone-client python-ubuntuone-control-panel python-ubuntuone-storageprotocol python-uno rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-magnatune rhythmbox-plugin-zeitgeist rhythmbox-plugins rhythmbox-ubuntuone shotwell thunderbird thunderbird-globalmenu thunderbird-gnome-support thunderbird-locale-en thunderbird-locale-en-us totem totem-common totem-mozilla totem-plugins transmission-common transmission-gtk ubuntuone-client ubuntuone-client-gnome ubuntuone-control-panel ubuntuone-couch ubuntuone-installer unity-scope-musicstores uno-libs3 ure libexttextcat0 libmtp9 libcmis-0.2-0 libdiscid0 libdmapsharing-3.0-2 libevent-2.0-5 libexiv2-11 libgexiv2-1 libgpod4 libhyphen0 liblircclient0 libmhash2 libmusicbrainz3-6 libmythes-1.2-0 libneon27-gnutls libprotoc7 libraptor2-0 librasqal3 libraw5 librdf0 libwpd-0.9-9 libwpg-0.2-2 libwps-0.2-2 libyajl1 xfonts-mathml

[ -f /etc/init/avahi-daemon.conf ] && sudo patch -p0 < avahi-daemon.diff
[ -f /etc/init/bluetooth.conf ] && sudo patch -p0 < bluetooth.diff
[ -f /etc/init/cups.conf ] && sudo patch -p0 < cups.diff
[ -f /etc/init/lightdm.conf ] && sudo patch -p0 < lightdm.diff
[ -f /etc/init/whoopsie.conf ] && sudo patch -p0 < whoopsie.diff

# install [H] kernel
sudo dpkg -P linux-image-generic-lts-quantal  linux-generic-lts-quantal 'linux-image-3.[56789].*' 'linux-image-extra-3.[56789].*'
sudo dpkg -P linux-headers-generic-lts-quantal 'linux-headers-3.[56789].*'
sudo dpkg -i linux-*.deb
rm linux-*.deb

sudo apt-get -y install dconf-tools ncurses-dev g++
sudo apt-get clean
if [ -d /usr/share/backgrounds ]; then
  sudo cp h.png /usr/share/backgrounds/
  sudo touch -d '2013-06-03 06:05' /usr/share/backgrounds/h.png
fi
sudo cp 10_gsettings-desktop-schemas.gschema.override /usr/share/glib-2.0/schemas/10_gsettings-desktop-schemas.gschema.override
sudo cp 10_libgnome2-common /usr/share/gconf/defaults/10_libgnome2-common
sudo cp com.canonical.unity-greeter.gschema.xml /usr/share/glib-2.0/schemas/com.canonical.unity-greeter.gschema.xml
sudo cp ubuntu-wallpapers.xml /usr/share/gnome-background-properties/ubuntu-wallpapers.xml
sudo cp org.gnome.desktop.screensaver.gschema.xml /usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.xml
cp /var/lib/gconf/debian.defaults/%gconf-tree.xml /dev/shm/%gconf-tree.xml-backup
cat /var/lib/gconf/debian.defaults/%gconf-tree.xml  | awk '/entry name/ { W=$2 ; T=$3 ; print ; next } ; { if (W == "name=\"primary_color\"") { print "\t\t\t\t\t<stringvalue>#000000</stringvalue>" ; print "\t\t\t\t</entry>" ; print "\t\t\t\t<entry name=\"secondary_color\" " T " type=\"string\">" ; print "\t\t\t\t\t<stringvalue>#000000</stringvalue>" ; W="" ; next } ; if (W == "name=\"picture_options\"") { print "\t\t\t\t\t<stringvalue>centered</stringvalue>" ; W="" ; next } ; if (W == "name=\"picture_filename\"") { print "\t\t\t\t\t<stringvalue>/usr/share/backgrounds/h.png</stringvalue>" ; W="" ; next } ; print }' > /dev/shm/%gconf-tree.xml
sudo dd bs=4k if=/dev/shm/%gconf-tree.xml of=/var/lib/gconf/debian.defaults/%gconf-tree.xml
cd /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas .
cd -

sudo cp hostname-persistent /usr/bin/
sudo cp horde-hostname.conf /etc/init/
sudo ln -s /lib/init/upstart-job /etc/init.d/horde-hostname
tar -xzf langouste3-15.9.tar.gz
cd langouste3-15.9
make
sudo make install
cd -
tar -xzf tpc-0.44-rc2-src.tar.gz
cd tpc-0.44-rc2-src
make
sudo make install
cd -
tar -xzf i7z-0.27.2.tar.gz
cd i7z-0.27.2
make
sudo make install
cd -
tar -xzf ocng-utils-4.3.tar.gz
cd ocng-utils-4.3
make
sudo make install
cd -

wget https://raw.github.com/team33/hfminstall/master/hfminstall
chmod +x hfminstall
sudo ./hfminstall
sudo apt-get clean

cd /usr/bin
sudo wget https://raw.github.com/team33/fahinstall/$FAHINSTALL_BRANCH/fahinstall
sudo chmod +x fahinstall
cd -

sudo sed -i 's/^exit 0/sudo -u horde langouste3 -l 8880 -D\nexit 0/' /etc/rc.local

cp hfm.hfmx ~/.hfm.hfmx
cp DOUBLE*ME ~/Desktop/

mkdir ~/fah/
cp /usr/share/langouste3/langouste-helper.sh ~/fah/

sudo fahinstall -F -S -t /dev/shm -b $FAHINSTALL_BRANCH
sudo apt-get clean

gvfs-set-attribute ~/Desktop/HFM.desktop metadata::nautilus-icon-position 64,10
gvfs-set-attribute ~/Desktop/DOUBLE-CLICK\ ME metadata::nautilus-icon-position 424,177
sed -r -i 's/^(nautilus-icon-view-keep-aligned)=.*$/\1=false/' ~/.config/nautilus/desktop-metadata


dconf write /desktop/unity/launcher/favorites "['nautilus-home.desktop','firefox.desktop','ubuntu-software-center.desktop','gnome-control-center.desktop','gnome-terminal.desktop']"
cp %gconf.xml ~/.gconf/apps/gnome-terminal/profiles/Default/

echo
echo Success!
echo
echo Now, execute \'ulimit -n 0\', close terminal and power-off the machine,
echo then zip the image and you\'re done!

#ulimit -n 0
# close terminal
# power off (from the panel)
