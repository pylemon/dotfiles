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
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod1"
modkey_win = "Mod4"

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
   names  = { "1.Term", "2.Emacs", "3.Firefox", "4.vBox", "5.Chat", "6.Mail" },
   layout = { layouts[2], layouts[3], layouts[3], layouts[3], layouts[2], layouts[3] }
}
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}


--{{{ dropdown terminal  Modkey-F1 to call a dropdown emacsclient
-- This function is for awesome versions prior to 3.4
dropdown = {}
function dropdown_toggle(prog, height, s)
   if s == nil then s = mouse.screen end
   if height == nil then height = 0.99 end   
   if not dropdown[prog] then
      -- Create table
      dropdown[prog] = {}      
      -- Add unmanage hook for dropdown programs
      awful.hooks.unmanage.register(function (c)
                                       for scr, cl in pairs(dropdown[prog]) do
                                          if cl == c then
                                             dropdown[prog][scr] = nil
                                          end
                                       end
                                    end)
   end   
   if not dropdown[prog][s] then
      spawnw = function (c)
                  -- Store client
                  dropdown[prog][s] = c                  
                  -- Float client
                  awful.client.floating.set(c, true)                  
                  -- Get screen geometry
                  screengeom = screen[s].workarea                  
                  -- Calculate height
                  if height < 1 then
                     height = screengeom.height*height
                  end
                  -- I like a different border with for the popup window
                  -- So I don't confuse it with terminals in the layout
                  bw = 2
                  -- Resize client
                  c:geometry({
                                x = screengeom.x,
                                y = screengeom.y - 1000,
                                width = screengeom.width - bw, 
                                height = height - bw
                             })
                  -- Mark terminal as ontop
                  --            c.ontop = true
                  --            c.above = true
                  c.border_width = bw
                  -- Focus and raise client
                  c:raise()
                  client.focus = c
                  -- Remove hook
                  awful.hooks.manage.unregister(spawnw)
               end
      -- Add hook
      awful.hooks.manage.register(spawnw)
      -- Spawn program
      awful.util.spawn(prog)
      dropdown.currtag = awful.tag.selected(s)
   else
      -- Get client
      c = dropdown[prog][s]      
      -- Switch the client to the current workspace
      -- Focus and raise if not hidden
      if c.hidden then
         awful.client.movetotag(awful.tag.selected(s), c)
         c.hidden = false
         c:raise()
         client.focus = c
      else
         if awful.tag.selected(s) == dropdown.currtag then
            c.hidden = true
            local ctags = c:tags()
            for i, t in pairs(ctags) do
               ctags[i] = nil
            end
            c:tags(ctags)
         else
            awful.client.movetotag(awful.tag.selected(s), c)
            c:raise()
            client.focus = c
         end
      end
      dropdown.currtag = awful.tag.selected(s)
   end
end
-- }}}


-- {{{ Autorun programs
-- 自动启动程序
autorun = true
autorunApps =
{
   "/home/liwei/Software/goagent/local/proxy.py",
   "killall nm-applet",
   "killall urxvtd",
   "killall emacs",
   "gnome-settings-daemon",
   "pidgin",
   "thunderbird",
   "xcompmgr -CcfF -I20 -O10 -D1 -t-5 -l-5 -r4.2 -o.82"
}

if autorun then
    for app = 1, #autorunApps do
	awful.util.spawn_with_shell(autorunApps[app])
    end
end
-- }}}


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
seperator = widget({ type = "textbox" })
dash = widget({ type = "textbox" })
spacer.text = " "
seperator.text = "|"
dash.text = "-"

-- {{{ Wibox

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
baticon = widget({ type = "imagebox" })
baticon.image = image("/home/liwei/.config/awesome/icons/bat-blue.png")
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image("/home/liwei/.config/awesome/icons/cpuinfow-green.png")
memicon = widget({ type = "imagebox" })
memicon.image = image("/home/liwei/.config/awesome/icons/cpuinfow-blue.png")
timeicon = widget({ type = "imagebox" })
timeicon.image = image("/home/liwei/.config/awesome/icons/time-red.png")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
-- mypromptbox = {}
-- mylayoutbox = {}
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
    -- Create a promptbox for each screen
    -- mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright, prompt = "" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    -- mylayoutbox[s] = awful.widget.layoutbox(s)
    -- mylayoutbox[s]:buttons(awful.util.table.join(
    --                        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    --                        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    --                        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    --                        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
					     return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = 0, border_color = "#FFFFFF" })
   -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mytaglist[s],
	    layout = awful.widget.layout.horizontal.leftright
        },
	mytextclock, tzswidget, 
	cpuwidget, spacer, 
	memwidget, spacer, 
	batwidget, spacer, 
	mysystray, mytasklist[s],	
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
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

    -- M-Esc 切换到上一个 tag
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

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
    awful.key({ modkey }, "r",
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

    --Volume manipulation  
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 5+") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 5-") end),

    -- C-M-j C-M-k 切换 screen
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    -- 切换到 高亮的 tag
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

    -- 自定义启动的程序
    awful.key({ modkey, "Control" }, "e", function () awful.util.spawn("emacsclient -c -e '(reset-default-font)'") end),
    awful.key({ modkey, "Control" }, "f", function () awful.util.spawn("pcmanfm") end),
    awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("slock") end),
    awful.key({ modkey,           }, "F1", function() dropdown_toggle('urxvtc -g 170x49 -e emacsclient -tc') end),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    
    -- 重启和退出 awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- 增加或者减少 窗口面积
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end)
)

clientkeys = awful.util.table.join(

    -- 关闭当前高亮程序
    awful.key({ modkey, "Control" }, "c",      function (c) c:kill()                         end),
    
    -- 移动当前程序到下一个 screen
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),

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
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
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
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][6] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- {{{ Tag signal handler - selection
--   - ASCII tags 1 [2] 3 4...
--   - start with tag 1 named [1] in tag setup
-- for s = 1, screen.count() do
--     for t = 1, #tags[s] do
--         tags[s][t]:add_signal("property::selected", function ()
--            if tags[s][t].selected then
--                 tags[s][t].name = "[" .. tags[s][t].name .. "]"
--             else
--                 tags[s][t].name = tags[s][t].name:gsub("[%[%]]", "")
--             end
--         end)
--     end
-- end
-- }}}

-- some command on startup
os.execute("nm-applet &")
os.execute("emacs --daemon")
os.execute("urxvtd &")
