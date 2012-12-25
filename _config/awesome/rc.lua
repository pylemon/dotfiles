local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init(awful.util.getdir("config") .. "/themes/dust/theme.lua")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local wi = require("wi")


-- {{{ Error handling
-- Startup
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors })
end

-- Runtime
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
      if in_error then return end
      in_error = true

      naughty.notify({ preset = naughty.config.presets.critical,
          title = "Oops, an error happened!",
          text = err })
      in_error = false
    end)
end
-- }}}

-- {{{ Variables
terminal = "lxterminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"
modkey_alt = "Mod1"
-- }}}

-- {{{ Layouts
local layouts =
{
    awful.layout.suit.floating,                  -- 1
    awful.layout.suit.tile.left,                 -- 2
    awful.layout.suit.max                        -- 3
}
-- }}}

-- {{{ Naughty presets
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top"
naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "profont"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = 256
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = 1
naughty.config.defaults.hover_timeout = nil
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Tags
tags = {
   names  = { "1.Term", "2.Emacs", "3.Chrome", "4.Mail"},
   layouts = { layouts[2], layouts[3], layouts[3], layouts[3] }
}
for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layouts)
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
run_once("tilda")
run_once("ssh liwei@pylemon -ND 10086 -v")
run_once("skype")
run_once("thunderbird")
run_once("killall emacs")
-- }}}

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



-- Menubar
menubar.utils.terminal = terminal

-- Clock
mytextclock = awful.widget.textclock("<span color='" .. beautiful.fg_em .. "'>%a %Y/%m/%d</span> @ %H:%M %p")

-- {{{ Wiboxes
mywibox = {}
mygraphbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function(c)
      if c == client.focus then
        c.minimized = true
      else
        c.minimized = false
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
      end
    end),
  awful.button({ }, 3, function()
      if instance then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ width=250 })
      end
    end),
  awful.button({ }, 4, function()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.button({ }, 5, function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end))

for s = 1, screen.count() do
  -- Layoutbox
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
      awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
      awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
      awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
      awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)))

  -- Taglist
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Tasklist
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Wibox
  mywibox[s] = awful.wibox({ position = "top", height = 16, screen = s })

  local left_wibox = wibox.layout.fixed.horizontal()
  left_wibox:add(mytaglist[s])

  local right_wibox = wibox.layout.fixed.horizontal()
  right_wibox:add(space)
  if s == 1 then right_wibox:add(wibox.widget.systray()) end
  right_wibox:add(space)
  -- right_wibox:add(baticon)
  -- right_wibox:add(batpct)
  right_wibox:add(rootfspct)
  right_wibox:add(cpupct1)
  right_wibox:add(cpugraph1)
  right_wibox:add(space)
  right_wibox:add(memused)
  right_wibox:add(membar)
  right_wibox:add(space)
  right_wibox:add(downwidget)
  right_wibox:add(space)
  right_wibox:add(mytextclock)
  right_wibox:add(space)
  right_wibox:add(mylayoutbox[s])

  local wibox_layout = wibox.layout.align.horizontal()
  wibox_layout:set_left(left_wibox)
  wibox_layout:set_middle(mytasklist[s])
  wibox_layout:set_right(right_wibox)

  mywibox[s]:set_widget(wibox_layout)
end
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
   awful.key({ modkey,                 }, "f", function(c) c.fullscreen = not c.fullscreen end),

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

keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber))
end

for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i].selected then
          awful.tag.history.restore(screen)
        elseif tags[screen][i] then
          awful.tag.viewonly(tags[screen][i])
        end
      end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewtoggle(tags[screen][i])
        end
      end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.movetotag(tags[client.focus.screen][i])
        end
      end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.toggletag(tags[client.focus.screen][i])
        end
      end))
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
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
      properties = { floating = true, opacity = 0.8 },
    -- flash player fullscreen
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
      callback = function( c )
	 c:geometry( { width = 700 , height = 500 } )
      end },
    -- { rule = { class = "Emacs" },
    --   properties = { tag = tags[1][2] } },
    -- { rule = { class = "Google-chrome" },
    --   properties = { tag = tags[1][3] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
