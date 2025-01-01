local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Reload config
hs.hotkey.bind(hyper, "r", function()
	hs.reload()
end)

local inspect = hs.inspect.inspect

-- Apllication switcher
local applicationHotkeys = {
	f = "Firefox",
	e = "Arc",
	n = "Ghostty",
	b = "OBS",
	d = "Discord",
	s = "Slack",
	y = "System Preferences",
	i = "Safari",
	w = "WhatsApp",
	a = "Finder",
	g = "Google Chrome",
	o = "Spotify",
}

for key, app in pairs(applicationHotkeys) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

-- Hotkey to toggle light/dark mode
hs.hotkey.bind(hyper, "T", function()
	local _, isDarkMode = hs.osascript.applescript([[
        tell application "System Events"
            tell appearance preferences
                return dark mode
            end tell
        end tell
    ]])

	-- Toggle the macOS appearance mode
	hs.osascript.applescript([[
        tell application "System Events"
            tell appearance preferences
                set dark mode to not dark mode
            end tell
        end tell
    ]])

	-- Notify the user
	if isDarkMode then
		hs.alert.show("Switched to Light Mode")
	else
		hs.alert.show("Switched to Dark Mode")
	end
end)

-- Show the time
hs.loadSpoon("AClock")
hs.hotkey.bind(hyper, "c", function()
	spoon.AClock:toggleShow()
end)

-- Emoji picker
hs.loadSpoon("Emojis")
spoon.Emojis:bindHotkeys({ toggle = { hyper, "j" } })

-- Currently playing song
hs.hotkey.bind(hyper, "p", function()
	local track = hs.spotify.getCurrentTrack()
	local artist = hs.spotify.getCurrentArtist()
	local album = hs.spotify.getCurrentAlbum()
	local albumArt = hs.spotify.getCurrentTrackArtworkURL()

	hs.image.imageFromURL(albumArt, function(image)
		image:size({ h = 200, w = 200 })
		hs.alert.showWithImage(
			string.format(
				"Track: %s\nArtist: %s\nAlbum: %s",
				track,
				artist,
				album
			),
			image,
			4
		)
	end)
end)

local slackHotkeyMap = {
	["j"] = "down",
	["k"] = "up",
	["l"] = "right",
	["h"] = "left",
	["n"] = "down",
	["p"] = "up",
	["c"] = "Escape",
}
-- Enable ctrl + hjkl/np for triggering arrow keys in slack
SlackHotkeys = {}
for key, value in pairs(slackHotkeyMap) do
	SlackHotkeys[key] = hs.hotkey.new({ "ctrl" }, key, function()
		hs.eventtap.keyStroke({}, value, 0)
	end)
end

SlackWatcher = hs.application.watcher.new(function(appName, eventType)
	if appName == "Slack" and eventType == hs.application.watcher.activated then
		for key in pairs(SlackHotkeys) do
			SlackHotkeys[key]:enable()
		end
	end
	if
		appName == "Slack"
		and eventType == hs.application.watcher.deactivated
	then
		for key in pairs(SlackHotkeys) do
			SlackHotkeys[key]:delete()
		end
	end
end)
SlackWatcher:start()

hs.alert.show("Config reloaded")
