-- Discord Webhook (if Config.Discord is set to true)
local discordWebhook = ''

function sendToDiscord(color, name, message, footer)
	local embed = {
		{
			["color"] = color,
			["title"] = "**".. name .."**",
			["description"] = message,
			["footer"] = {
				["text"] = footer,
			},
		}
	}
  
	PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end