local M = {}

local hyper = { "cmd", "alt", "ctrl", "shift" }

local config = {
	episodes = {
		{
			id = 1,
			name = "webrtc",
			links = {
				{
					name = "presenter",
					secretKey = "EWgfbipnNT7F7h2wCYHKmEh0uLRYza6hz-kTdUjFYKU",
				},
				{
					name = "copresenter",
					secretKey = "9-QGn37ur8u5ixBsGBVQGty6238KRTBhSOxKwk7S4WI",
				},
				{
					name = "moderator",
					secretKey = "z1wBLHkmzZ08G0jzbC9TqyEdtHXBIbtscLzQWgUNbN8",
				},
				{
					name = "operator",
					secretKey = "XQ3Re10sX7jm8ge5_4WLoblZfIbZR1f9qWS-9U-p18A",
				},
				{
					name = "2ndCopresenter",
					secretKey = "mb2GIY3OuiuXoJhmssZf3WFDaciL6D70yndGXSSGJPI",
				},
				{
					name = "viewer",
					secretKey = "Vzkh894iD1vTszlzM0c36F_qk2-vNyyNA0UNoCGihZY",
				},
			},
		},
		{
			id = 4,
			name = "rtmp",
			links = {
				{
					name = "presenter",
					secretKey = "cXi50v6DgwNscYYsoXzNP4G0BLp3HnAaFBVY6gqDPQM",
				},
				{
					name = "moderator",
					secretKey = "iOQqGPPDeeOlWPBdqs90dssCCeXJZTPbN9v7nAUPoPo",
				},
			},
		},
		{
			id = 5,
			name = "automated",
			links = {},
		},
		{
			id = 14,
			name = "sales-page",
			links = {},
		},
		{
			id = 29,
			name = "with-all-reg",
			links = {},
		},
		{
			id = 54,
			name = "paid-1",
			links = {},
		},
	},
}

local modes = {
	"dashboard",
	"registration",
	"page_editor",
	"embed_builder",
	"streaming",
}

-- Function to open a URL in the default browser
local function openLink(url)
	hs.urlevent.openURL(url)
end

-- Pass to chooser:queryChangedCallback to quickly select a choice
local quickSelect = function(chooser, choices)
	return function(query)
		if string.len(query) ~= 1 then
			return
		end
		for index, value in ipairs(choices) do
			if query == value.key then
				chooser:select(index)
				break
			end
		end
	end
end

local function choose(choices, callback)
	local chooser = hs.chooser.new(function(selected)
		hs.alert.show(selected)
	end)
	chooser:choices(choices)
	chooser:show()
end

-- Function to prompt user for episode selection
local function selectEpisode(callback)
	local choices = {}
	for _, episode in ipairs(config.episodes) do
		table.insert(choices, {
			text = episode.name,
			subText = "Episode ID: " .. episode.id,
			episodeId = episode.id,
			name = episode.name,
			key = string.sub(episode.name, 1, 1),
		})
	end

	local chooser = hs.chooser.new(function(selected)
		if selected then
			callback(selected.episodeId, selected.name)
		end
	end)
	chooser:choices(choices)
	chooser:placeholderText("Select episode")
	chooser:queryChangedCallback(quickSelect(chooser, choices))
	chooser:show()
end

-- Function to prompt user for mode selection
local function selectMode(callback)
	local choices = {}
	for _, mode in ipairs(modes) do
		table.insert(choices, {
			text = mode,
			mode = mode,
			key = string.sub(mode, 1, 1),
		})
	end

	local chooser = hs.chooser.new(function(selected)
		if selected then
			callback(selected.mode)
		end
	end)
	chooser:choices(choices)
	chooser:placeholderText("Select mode")
	chooser:queryChangedCallback(quickSelect(chooser, choices))
	chooser:show()
end

-- Function to prompt user for role selection (if needed)
local function selectRole(episodeId, callback)
	local episode = nil
	for _, e in ipairs(config.episodes) do
		if e.id == episodeId then
			episode = e
			break
		end
	end

	if not episode then
		hs.alert.show("Episode not found!")
		return
	end

	local choices = {}
	for _, link in ipairs(episode.links) do
		table.insert(choices, {
			text = link.name,
			role = link.name,
			key = string.sub(link.name, 1, 1),
		})
	end

	local chooser = hs.chooser.new(function(selected)
		if selected then
			callback(selected.role)
		end
	end)
	chooser:choices(choices)
	chooser:placeholderText("Select role")
	chooser:queryChangedCallback(quickSelect(chooser, choices))
	chooser:show()
end

-- Function to prompt for dry run confirmation
local function confirmDryRun(callback)
	local choices = {
		{ text = "Yes", dryRun = true, key = "y" },
		{ text = "No", dryRun = false, key = "n" },
	}

	local chooser = hs.chooser.new(function(selected)
		if selected then
			callback(selected.dryRun)
		end
	end)
	chooser:choices(choices)
	chooser:placeholderText("Open as dry run")
	chooser:queryChangedCallback(quickSelect(chooser, choices))
	chooser:show()
end

-- Main function to execute based on user input
local function run(args)
	local mode, episodeId, role, dryRun, name =
		args.mode, args.episodeId, args.role, args.dryRun, args.name

	if mode == "dashboard" then
		openLink("http://localhost:3000/admin/episodes/" .. episodeId)
	elseif mode == "registration" then
		openLink(
			"http://localhost:3000/domain/admin-account.localhost/" .. name
		)
	elseif mode == "page_editor" then
		openLink(
			"http://localhost:3000/admin/episodes/"
				.. episodeId
				.. "/registration_page/edit_template"
		)
	elseif mode == "embed_builder" then
		openLink(
			"http://localhost:3000/admin/episodes/"
				.. episodeId
				.. "/embed_registration_page"
		)
	elseif mode == "streaming" then
		local episode = nil
		for _, e in ipairs(config.episodes) do
			if e.id == episodeId then
				episode = e
				break
			end
		end
		if not episode then
			hs.alert.show("Episode not found!")
			return
		end

		local secretKey = nil
		for _, link in ipairs(episode.links) do
			if link.name == role then
				secretKey = link.secretKey
				break
			end
		end

		if not secretKey then
			hs.alert.show(
				"Secret key for role " .. (role or "unknown") .. " not found"
			)
			return
		end

		local baseLink =
			"http://localhost:3000/domain/admin-account.localhost/manage/"
		local link = baseLink .. secretKey .. (dryRun and "/dry_run" or "")
		openLink(link)
	end
end

-- Interactive flow
local function startInteractive()
	selectEpisode(function(episodeId, name)
		selectMode(function(mode)
			if mode == "streaming" then
				selectRole(episodeId, function(role)
					confirmDryRun(function(dryRun)
						run({
							episodeId = episodeId,
							mode = mode,
							role = role,
							dryRun = dryRun,
							name = name,
						})
					end)
				end)
			else
				run({ episodeId = episodeId, name = name, mode = mode })
			end
		end)
	end)
end

function M.init()
	hs.hotkey.bind(hyper, "k", function()
		startInteractive()
	end)
end

return M
