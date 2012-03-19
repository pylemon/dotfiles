-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("debian.menu")
require("wicked")


-- {{{ CPU graph view
-- cpu widget  graph view
cpugraphwidget = widget({
    type = 'graph',
    name = 'cpugraphwidget',
    align = 'right'
})
cpugraphwidget.height = 0.8
cpugraphwidget.width = 45
cpugraphwidget.bg = '#111111'
cpugraphwidget.border_color = '#0a0a0a'
cpugraphwidget.grow = 'left'
cpugraphwidget:plot_properties_set('cpu', {
    fg = '#AEC6D8',
    fg_center = '#285577',
    fg_end = '#285577',
    vertical_gradient = false
})
wicked.register(cpugraphwidget, wicked.widgets.cpu, '$1', 1, 'cpu')
-- }}}


-- {{{ MEM widget
-- mem widget 1023M
memwidget = widget({
    type = 'textbox',
    name = 'memwidget'
})
wicked.register(memwidget, wicked.widgets.mem,
    ' MEM: <span color="#888888">$2M</span> CPU: ')
-- }}}


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/theme.lua")

-- Private naughty config
naughty.config.default_preset.font = "微软雅黑Monaco 10"
naughty.config.default_preset.position = "top_right"
naughty.config.default_preset.fg = beautiful.fg_focus
naughty.config.default_preset.bg = beautiful.bg_focus
naughty.config.default_preset.border_color = beautiful.border_focus

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
		     title = "Oops, there were errors during startup!",
		     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
	-- Make sure we don't go into an endless error loop
	if in_error then return end
	in_error = true

	naughty.notify({ preset = naughty.config.presets.critical,
			 title = "Oops, an error happened!",
			 text = err })
	in_error = false
    end)
end
-- }}}

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
browser = "firefox"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,		-- 1
    awful.layout.suit.tile,		-- 2
    awful.layout.suit.tile.left,	-- 3
    awful.layout.suit.tile.bottom,	-- 4
    awful.layout.suit.tile.top,		-- 5
    awful.layout.suit.fair,		-- 6
    awful.layout.suit.fair.horizontal,	-- 7
    awful.layout.suit.spiral,		-- 8
    awful.layout.suit.spiral.dwindle,	-- 9
    awful.layout.suit.max,		-- 10
    awful.layout.suit.max.fullscreen,	-- 11
    awful.layout.suit.magnifier		-- 12
}
-- }}}


-- {{{ Tags
tags = {}
-- 自定义 tags 标签名称
tags[1] = awful.tag(
   { "1.Term",  "2.Emacs", "3.Firefox", "4.Pidgin", "5.WebQQ", "6.Email"  }, 1,
   { layouts[3], layouts[10],  layouts[10], layouts[3], layouts[10], layouts[10] }
)
-- 如果外接显示器 自定义标签如下
if screen.count()==2 then
   tags[2] = awful.tag(
      { "screen2", }, 2,
      { layouts[10], })
end
-- }}}



-- {{{ Autorun programs
-- 自动启动程序
autorun = true
autorunApps =
{
    "/home/liwei/.qq",
    "pidgin",
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
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
				    { "Debian", debian.menu.Debian_menu.Debian },
				    { "open terminal", terminal },
				    { "restart awesome", awesome.restart }
				  }
			})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
				     menu = mymainmenu })
-- }}}


-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, " %a %b %d %H:%M ", 1)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Private decoration
myicon = widget({ type = "imagebox" })
myicon.image = image(beautiful.awesome_icon)
myspace = widget({ type = "textbox" })
myspace.text = " "

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
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
					      if c == client.focus then
						  c.minimized = true
					      else
						  if not c:isvisible() then
						      awful.tag.viewonly(c:tags()[1])
						  end
						  -- This will also un-minimize
						  -- the client, if needed
						  client.focus = c
						  c:raise()
					      end
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
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
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
    mywibox[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
	mylayoutbox[s],
	myspace,
	mytextclock,
	cpugraphwidget,
	memwidget,
	s == 1 and mysystray or nil,
	myspace,
	{
	   mytaglist[s],
	   mypromptbox[s],
	   layout = awful.widget.layout.horizontal.leftright
	},
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
    awful.key({ modkey, "Control" }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey, "Control" }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

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
    awful.key({ modkey, "Shift"   }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, "Shift"   }, "Tab",
	function ()
	    awful.client.focus.history.previous()
	    if client.focus then
		client.focus:raise()
	    end
	end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),

    -- emacs and firefox start
    awful.key({ modkey, "Control" }, "e", function () awful.util.spawn("emacsclient -nc") end),
    awful.key({ modkey, "Control" }, "f", function () awful.util.spawn(browser) end),

    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    -- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    -- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey, "Control" }, "x",
	      function ()
		  awful.prompt.run({ prompt = "Run Lua code: " },
		  mypromptbox[mouse.screen].widget,
		  awful.util.eval, nil,
		  awful.util.getdir("cache") .. "/history_eval")
	      end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift"   }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Control", "Shift"   }, "n",
	function (c)
	    -- The client currently has the input focus, so it cannot be
	    -- minimized, since minimized clients can't have the focus.
	    c.minimized = true
	end),
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
-- }}}

-- 设置程序窗口位置
-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
		     border_color = beautiful.border_normal,
		     focus = true,
		     keys = clientkeys,
		     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },

    -- { rule = { class = "urxvt" },
    --   properties = { tag = tags[1][1] } },
    -- { rule = { class = "Emacs" },
    --   properties = { tag = tags[1][2] } },
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][3] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Prism" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][6] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
	    and awful.client.focus.filter(c) then
	    client.focus = c
	end
    end)

    if not startup then
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- awful.client.setslave(c)

	-- Put windows in a smart way, only if they does not set an initial position.
	if not c.size_hints.user_position and not c.size_hints.program_position then
	    awful.placement.no_overlap(c)
	    awful.placement.no_offscreen(c)
	end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
