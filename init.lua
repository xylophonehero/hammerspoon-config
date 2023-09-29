local hyper = { "cmd", "alt", "ctrl", "shift" }

local applicationHotkeys = {
	u = "Kit",
	f = "Firefox",
	t = "Visual Studio Code",
	e = "Google Chrome",
	n = "iTerm",
	r = "OBS",
	d = "Discord",
	s = "Slack",
	y = "System Preferences",
	i = "Safari",
}

local chromeApps = {
	m = "Gmail",
	o = "Spotify",
	w = "WhatsApp",
}

function openChromeApp(name)
	return function()
		-- Be sure to get the real name of the app (Use ls -a to check).
		hs.application.launchOrFocus(os.getenv("HOME") .. "/Applications/Chrome Apps.localized/" .. name .. ".app")
	end
end

for key, app in pairs(applicationHotkeys) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

for key, app in pairs(chromeApps) do
	hs.hotkey.bind(hyper, key, openChromeApp(app))
end
