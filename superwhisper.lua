-- CONFIGURATION --
local recordingPath = os.getenv("HOME") .. "/Documents/SuperWhisper/Recordings/"
local recordingHotkey = { "alt" } -- Option key only (⌥ Space)

local json = require("hs.json")

local function readJSONFile(filePath)
	local file = io.open(filePath, "r")
	if not file then
		print("Could not open file: " .. filePath)
		return nil
	end

	local content = file:read("*all")
	file:close()

	local jsonData = json.decode(content)
	if not jsonData then
		print("Could not decode JSON data")
		return nil
	end

	return jsonData
end

local function monitorFiles(path, callback)
	local watcher
	watcher = hs.pathwatcher.new(path, function(files)
		for _, file in ipairs(files) do
			local attr = hs.fs.attributes(file)
			if
				attr
				and attr.mode == "file"
				and hs.fs.displayName(file):sub(-5) == ".json"
			then
				hs.alert.show("File found: " .. file)

				local data = readJSONFile(file)
				if not data then
					hs.alert.show("Error reading JSON file: " .. file)
					return
				end

				callback(data)
				-- hs.alert.show(hs.inspect(data))
				-- hs.notify
				-- 	.new({
				-- 		title = "SuperWhisper",
				-- 		informativeText = "Recording finished: " .. file,
				-- 	})
				-- 	:send()Testing one two three.
				watcher:stop()
			end
		end
	end)
	watcher:start()
end

monitorFiles(recordingPath, function(data)
	hs.alert.show("New result:" .. data.result)
	hs.alert.show(hs.inspect(data))
	-- hs.alert.show("New recording found:" .. data.modelName)
end)

-- FUNCTION TO MONITOR NEW RECORDING FOLDERS --
local function monitorNewRecording(callback)
	local watcher
	watcher = hs.pathwatcher.new(recordingPath, function(files)
		for _, folder in ipairs(files) do
			local attr = hs.fs.attributes(folder)
			if attr and attr.mode == "directory" then
				hs.alert.show("Folder found: " .. folder)
				-- We found a new folder! Stop watching
				monitorFiles(folder, function(file)
					local data = readJSONFile(file)
					if not data then
						hs.alert.show("Error reading JSON file: " .. folder)
						return
					end
					hs.alert.show("New recording found:" .. data.modal)
					callback(data)
				end)
				watcher:stop()
			end
		end
	end)
	watcher:start()
end

-- FUNCTION TO START RECORDING --
local function startSuperWhisperRecording()
	-- Activate SuperWhisper and start recording
	-- hs.application.launchOrFocus("SuperWhisper")
	hs.timer.usleep(500000) -- Small delay for app activation

	-- Send ⌥ Space to start recording
	hs.eventtap.keyStroke(recordingHotkey, "space")

	-- Notify user
	hs.notify
		.new({ title = "SuperWhisper", informativeText = "Recording started." })
		:send()

	-- Start monitoring for new folders
	monitorNewRecording(function(data)
		hs.alert.show("New recording found:" .. data.modal)
	end)
end

-- SETUP HOTKEY --
local hyper = { "cmd", "alt", "ctrl", "shift" }
-- hs.hotkey.bind(hyper, "v", function()
-- 	startSuperWhisperRecording()
-- end)

hs.notify
	.new({
		title = "Hammerspoon",
		informativeText = "SuperWhisper control loaded. Press ⌘⌥R to start recording.",
	})
	:send()
