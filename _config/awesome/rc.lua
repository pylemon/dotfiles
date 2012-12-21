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
terminal = "lxterminal"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"
modkey_alt = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,                  -- 1
    awful.layout.suit.tile.left,                 -- 2
    awful.layout.suit.max                        -- 3
}
-- }}}

-- {{{ Tags
tags = {
   names  = { "1.Term", "2.Emacs", "3.Chrome", "4.Mail"},
   layout = { layouts[2], layouts[3], layouts[3], layouts[3] }
}
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}


-- {{{ Autorun programs
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end
run_once("xcompmgr -cF")
run_once("thunderbird")
run_once("tilda")
run_once("ssh liwei@pylemon -ND 8080 -v")
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
   "volti",
   "nm-applet",
   "gnome-settings-daemon",
   "/home/liwei/.dropbox-dist/dropboxd",
}

for k = 1, #procs do
	start_daemon(procs[k])
end
--- }}}


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


-- {{{ widgets
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

-- CPU widget
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu,
		 function (widget, args)
		    if string.len(args[1]) == 1 then
		       return "<span color='#1793d1'>☢  " .. args[1] .. "%</span>"
		    else
		       return "<span color='#1793d1'>☢ " .. args[1] .. "%</span>"
		    end
		 end)
cpuwidget:buttons(
   awful.util.table.join(awful.button({ }, 1, 
				      function ()
					 awful.util.spawn(terminal .. " -e htop")
				      end),
                         awful.button({ }, 3,
				      function ()
                                         cpuwidget.width = 1
				      end)))

-- Memory widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, 
                 function (widget, args)
                    return "<span color='#1793d1'>♻ " ..args[2].."M "..args[1].."%</span> "
                 end, 13)


-- Create a textclock widget
mytextclock = widget({ type = "textbox" })
vicious.register(mytextclock, vicious.widgets.date, "<span color='#1793d1'> %Y-%m-%d %a %T </span>", 1)

--Create icons
spicon = widget({ type = "imagebox" })
spicon.image = image("/home/liwei/.config/awesome/icons/separator.png")
spicon.resize = false
timeicon = widget({ type = "imagebox" })
timeicon.image = image("/home/liwei/.config/awesome/icons/wifi-blue.png")
timeicon.resize = false
mysystray = widget({ type = "systray" })
mysystray.resize = false

-- Create a wibox for each screen and add it
mywibox = {}
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
    mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = 1 })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
	    layout = awful.widget.layout.horizontal.leftright
        },
	mylayoutbox[s], mytextclock, tzswidget,
	memwidget, spacer,
	cpuwidget, spacer,
        s == 1 and mysystray or nil,
	mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    -- M-left, M-right 切换左右 tag
    awful.key({ modkey_alt, "Control" }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey_alt, "Control" }, "Right",  awful.tag.viewnext       ),

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

    -- using dmenu in awesome
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
    awful.key({                       }, "XF86PowerOff", function () suspend() end),

    -- C-M-j C-M-k switch screen
    awful.key({ modkey_alt, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey_alt, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

    -- jump to alert tag
    awful.key({ modkey,               }, "u", awful.client.urgent.jumpto),

    -- some useful software control keys
    awful.key({ modkey_alt, "Control" }, "e", function () awful.util.spawn("emacsclient -a '' -c") end),
    awful.key({ modkey_alt, "Control" }, "f", function () awful.util.spawn("nautilus --no-desktop") end),
    awful.key({ modkey_alt, "Control" }, "l", function () awful.util.spawn("slock") end),
    awful.key({ modkey_alt, "Control" }, "g", function () awful.util.spawn("google-chrome") end),
    awful.key({ modkey_alt,           }, "Return", function () awful.util.spawn(terminal) end),

    -- touchpad control
    -- awful.key({                   }, "XF86WebCam", function () awful.util.spawn('synclient touchpadoff=0') end),

    -- restart and quit awesome 
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- layout control
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end)
)


clientkeys = awful.util.table.join(

    -- close current frame
    awful.key({ modkey_alt, "Control" }, "c", function (c) c:kill()        end),

    -- switch to next screen
    awful.key({ modkey,               }, "o", awful.client.movetoscreen),

    -- toggle maximized window
    awful.key({ modkey,               }, "m",
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
-- nice i3 feture, choose a window twice will get return prev window
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i].selected then
			    return awful.tag.history.restore()
			end
			if tags[screen][i] then
			   awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey_alt, "Control" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)
-- end of keybindings}}}

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
      properties = { floating = true, opacity = 0.8 },
    -- flash player fullscreen
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
      callback = function( c )
	 c:geometry( { width = 700 , height = 500 } )
      end },
    { rule = { class = "Emacs" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "google-chrome" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
