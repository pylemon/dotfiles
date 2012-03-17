#!/usr/bin/env bash

AWESOME_CONFIG_PATH=$HOME/.config/awesome

# 多屏配置
# VGA在LVDS右侧扩展显示内容
#xrandr --output VGA1 --right-of LVDS1 --auto
# VGA克隆显示LVDS显示的内容并设置分辨率为1280x800
#xrandr --output VGA1 --same-as LVDS1 --mode 1280x800
# 只使用外接VGA口显示器
# xrandr --output VGA1 --auto --output LVDS1 --off


# 设置系统语言为中文
export LC_CTYPE="zh_CN.UTF-8"
export LANG="zh_CN.UTF-8"

# 设置 shell proxy
# export http_proxy=http://127.0.0.1:8087

# 开机启动项目
######################################################################
# #TODO 不明原因启动awesome时 emacs 会占用cpu 100%
killall emacs

# 启动emacs deamon 方便使用 emacsclient (alias ex,et)
emacs --daemon &

# 启动urxvt deamon
urxvtd &

# 启动 tilda 下拉式虚拟终端
tilda &

# 启动fcitx
/usr/share/fcitx/bin/fcitx &

# 启动gae翻墙
cd /home/liwei/Software/goagent/local/ && python proxy.py &

# 启动dropbox
/home/liwei/.dropbox-dist/dropboxd &
# dropbox start -i


# 启动gnome tools
######################################################################
#启动屏保程序
gnome-screensaver &

#启用gnome的主题，否则你的awesome下的gnome程序会非常难看
gnome-settings-daemon &

#网络管理程序
nm-applet &




# 美化配置
# xsetroot -solid black &

#电源管理程序
# gnome-power-manager &

#声音配置
# gnome-sound-applet &

#自动更新程序
# update-notifier &
