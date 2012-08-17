require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("vicious")

-- {{{ Variable definitions

-- Themes define colours, icons, and wallpapers
beautiful.init("/home/liwei/.config/awesome/themes/niceandclean/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "roxterm"
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"
modkey_alt = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    -- awful.layout.suit.tile,                   -- 1
    awful.layout.suit.floating,                  -- 1
    awful.layout.suit.tile.left,                 -- 2
    -- awful.layout.suit.tile.bottom,            -- 3
    -- awful.layout.suit.tile.top,               -- 4
    -- awful.layout.suit.fair,                   -- 5
    -- awful.layout.suit.fair.horizontal,        -- 6
    -- awful.layout.suit.magnifier,              -- 7
    awful.layout.suit.max                        -- 3
}
-- }}}

-- {{{ Tags
tags = {
   names  = { "1.Term", "2.Emacs", "3.Chrome", "4.Firefox", "5.Vbox", "6.Mail" },
   layout = { layouts[2], layouts[3], layouts[3], layouts[3], layouts[2], layouts[3] }
}
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}


-- {{{ Autorun programs
-- 自动启动程序
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- run_once("fcitx")
run_once("xcompmgr")
run_once("kupfer")
run_once("tilda")
run_once("synclient touchpadoff=1")
-- run_once("pidgin")
-- run_once("thunderbird")
-- }}}


function suspend()
   os.execute("slock")
   os.execute("pm-suspend")
end


-- {{{ daemon
function start_daemon(dae)
	daeCheck = os.execute("ps -eF | grep -v grep | grep -w " .. dae)
	if (daeCheck ~= 0) then
		os.execute(dae .. " &")
	end
end

procs = {
   "gnome-settings-daemon",
   "gnome-keyring-daemon",
   "gnome-sound-applet",
   "nm-applet",
   "emacs --daemon",
   "gae"
}

for k = 1, #procs do
	start_daemon(procs[k])
end
--- }}}

-- The systray is a bit complex. We need to configure it to display
-- the right colors. Here is a link with more background about this:
--  http://thread.gmane.org/gmane.comp.window-managers.awesome/9028
xprop = assert(io.popen("xprop -root _NET_SUPPORTING_WM_CHECK"))
wid = xprop:read():match("^_NET_SUPPORTING_WM_CHECK.WINDOW.: window id # (0x[%S]+)$")
xprop:close()
if wid then
   wid = tonumber(wid) + 1
   os.execute("xprop -id " .. wid .. " -format _NET_SYSTEM_TRAY_COLORS 32c " ..
	      "-set _NET_SYSTEM_TRAY_COLORS " ..
	      "65535,65535,65535,65535,8670,8670,65535,32385,0,8670,65535,8670")
end

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
   { "shutdown", terminal .. " -e sudo halt -p" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
				    { "restart", awesome.restart },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- Separators
spacer = widget({ type = "textbox" })
spacer.text = " "
seperator = widget({ type = "textbox" })
seperator.text = "|"

-- color function convert value to color
function gradient(color, to_color, min, max, value)
    local function color2dec(c)
        return tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16)
    end
    local factor = 0
    if (value >= max ) then
        factor = 1
    elseif (value > min ) then
        factor = (value - min) / (max - min)
    end
    local red, green, blue = color2dec(color)
    local to_red, to_green, to_blue = color2dec(to_color)
    red   = red   + (factor * (to_red   - red))
    green = green + (factor * (to_green - green))
    blue  = blue  + (factor * (to_blue  - blue))
    -- dec2color
    return string.format("#%02x%02x%02x", red, green, blue)
end

-- Create a cpuwidget
local cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
   local text
   local cpu
   cpu = args[1]+args[2]+args[3]+args[4]
   cpu = math.floor(cpu/4)
   local color = gradient("#1793d1","#FF5656",0,100,cpu)
   text = string.format("<span color='%s'>%s</span>", color, cpu)
   text = text.."<span color='#1793d1'>%</span>"
   return text
end)
tzswidget = widget({ type = "textbox" })
vicious.register(tzswidget, vicious.widgets.thermal,
function (widget, args)
   local text
   local color = gradient("#1793d1","#FF5656",30,85,args[1])
   args[1] = string.format("<span color='%s'> %s</span>", color, args[1])
   text = args[1].."<span color='#1793d1'>C</span>"
   return text
end, 19, "thermal_zone0")

-- Create a memwidget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem,
function (widget, args)
   local text
   local color2 = gradient("#1793d1","#FF5656",20,7000,args[2])
   args[2] = string.format("<span color='%s'>%s</span>", color2, args[2])
   text = args[2].."<span color='#1793d1'>M</span>"
   return text
end, 13)

-- Create a batwidget
batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat,
function (widget, args)
   local text
   local color = gradient("#FF5656","#1793d1",10,100,args[2])
   args[2] = string.format("<span color='%s'>%s</span>", color, args[2])
   text = args[1]..args[2]
   return text
end, 32, "BAT1")

-- Create a textclock widget
mytextclock = widget({ type = "textbox" })
vicious.register(mytextclock, vicious.widgets.date, "<span color='#1793d1'> %Y/%m/%d %a %T </span>", 1)

--Create icons
spicon = widget({ type = "imagebox" })
spicon.image = image("/home/liwei/.config/awesome/icons/separator.png")
spicon.resize = false
baticon = widget({ type = "imagebox" })
baticon.image = image("/home/liwei/.config/awesome/icons/bat-blue.png")
baticon.resize = false
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image("/home/liwei/.config/awesome/icons/cpuinfo-blue.png")
cpuicon.resize = false
memicon = widget({ type = "imagebox" })
memicon.image = image("/home/liwei/.config/awesome/icons/cpuinfow-blue.png")
memicon.resize = false
timeicon = widget({ type = "imagebox" })
timeicon.image = image("/home/liwei/.config/awesome/icons/wifi-blue.png")
timeicon.resize = false
mysystray = widget({ type = "systray" })
mysystray.resize = false

-- Create a wibox for each screen and add it
mywibox = {}
-- mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Set a screen margin for borders
    awful.screen.padding( screen[s], {top = 0} )

    -- mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright, prompt = "" })
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                              awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                              awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                              awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                              awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
					     return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = 0 })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
	    layout = awful.widget.layout.horizontal.leftright
        },
	mylayoutbox[s], mytextclock, timeicon, spacer, tzswidget,
	cpuwidget, spacer, cpuicon, spacer,
	memwidget, spacer, memicon, spacer,
	batwidget, spacer, baticon, spacer,
        s == 1 and mysystray or nil,
	mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    -- M-left, M-right 切换左右 tag
    awful.key({ modkey_alt, "Control" }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey_alt, "Control" }, "Right",  awful.tag.viewnext       ),

    -- M-Esc 切换到上一个 tag
    awful.key({ modkey_alt,           }, "Tab", awful.tag.history.restore),

    -- M-j, M-k 切换程序
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- dmenu 集成到 awesome 启动或者跳转到程序
    awful.key({ modkey_alt,       }, "r",
    	      function ()
    		 local f_reader = io.popen( "dmenu_path | dmenu -b -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#1793d1'")
    		 local command = assert(f_reader:read('*a'))
    		 f_reader:close()
    		 if command == "" then return end
    		 -- Check throught the clients if the class match the command
    		 local lower_command=string.lower(command)
    		 for k, c in pairs(client.get()) do
    		    local class=string.lower(c.class)
    		    if string.match(class, lower_command) then
    		       for i, v in ipairs(c:tags()) do
    			  awful.tag.viewonly(v)
    			  c:raise()
    			  c.minimized = false
    			  return
    		       end
    		    end
    		 end
    		 awful.util.spawn(command)
    	      end),

    -- sleep and shutdown
    awful.key({}, "XF86PowerOff", function () suspend() end),

    -- C-M-j C-M-k 切换 screen
    awful.key({ modkey_alt, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey_alt, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    -- 切换到 高亮的 tag
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

    -- 自定义启动的程序
    awful.key({ modkey_alt, "Control" }, "e", function () awful.util.spawn("emacsclient -c") end),
    awful.key({ modkey_alt, "Control" }, "f", function () awful.util.spawn("thunar") end),
    awful.key({ modkey_alt, "Control" }, "l", function () awful.util.spawn("slock") end),
    awful.key({ modkey_alt, "Control" }, "g", function () awful.util.spawn("google-chrome") end),

    -- 打开关闭触摸板
    awful.key({                   }, "XF86WebCam", function () awful.util.spawn('synclient touchpadoff=0') end),

    -- 打开 terminal
    awful.key({ modkey_alt,       }, "Return", function () awful.util.spawn(terminal) end),

    -- 重启和退出 awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- 增加或者减少 窗口面积
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end)
)

clientkeys = awful.util.table.join(

    -- 关闭当前高亮程序
    awful.key({ modkey_alt, "Control" }, "c",      function (c) c:kill()                         end),

    -- 移动当前程序到下一个 screen
    awful.key({ modkey_alt,           }, "o",      awful.client.movetoscreen                        ),

    -- 最大化窗口 或 还原
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        -- awful.key({ modkey, "Control" }, "#" .. i + 9,
        --           function ()
        --               local screen = mouse.screen
        --               if tags[screen][i] then
        --                   awful.tag.viewtoggle(tags[screen][i])
        --               end
        --           end),
        awful.key({ modkey_alt, "Control" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end))
        -- awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        --           function ()
        --               if client.focus and tags[client.focus.screen][i] then
        --                   awful.client.toggletag(tags[client.focus.screen][i])
        --               end
        --           end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- end of keybindings
-- }}}



-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
		     size_hints_honor = false,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Kupfer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Download" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Wine" },
      properties = { floating = true } },

    { rule = { class = "Pidgin" },
      properties = { floating = true },
      callback = function( c )
	 c:geometry( { width = 700 , height = 500 } )
      end },

    -- flash 播放器全屏播放
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
    { rule = { class = "Chromium-browser" },
      properties = { tag = tags[1][3] } },
    -- { rule = { class = "Google-chrome" },
    --   properties = { tag = tags[1][3] } },
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Skype" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][5] } },
    -- { rule = { class = "Wine" },
    --   properties = { tag = tags[1][5] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][6] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
