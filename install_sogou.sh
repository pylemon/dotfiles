# before installing the deepin sogou, you need to completely uninstall the fcitx in ubuntu source
# using this command to make sure all the fcitx packages are really uninstalled
# $ sudo dpkg --get-selections | grep fcitx

mkdir /tmp/sogou
cd /tmp/sogou
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx_4.2.6.1-2deepin2_all.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-bin_4.2.6.1-2deepin2_i386.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-data_4.2.6.1-2deepin2_all.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-frontend-all_4.2.6.1-2deepin2_all.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-frontend-gtk2_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-frontend-gtk3_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-frontend-qt4_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-libs_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-module-dbus_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-modules_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-module-x11_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-pinyin_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx-skins/fcitx-skin-sogou_0.0.2_all.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx-sogoupinyin/fcitx-sogoupinyin_0.0.0-2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-table_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-table-all_4.2.6.1-2deepin2_all.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-table-wubi_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-tools_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/fcitx-ui-classic_4.2.6.1-2deepin2_amd64.deb
wget http://packages.linuxdeepin.com/deepin/pool/main/f/fcitx/gir1.2-fcitx-1.0_4.2.6.1-2deepin2_amd64.deb
sudo dpkg -i *.deb
sudo apt-get install fcitx-config-gtk
