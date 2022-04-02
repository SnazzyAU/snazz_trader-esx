ESX = nil
local coolDown = true
local startNPCDuration = false
local startTimer = false
local curRanPos
local timerFinished = false
local traderFinished = false
local spawned = false
local locationChosen = false
local trader
local itemValue
local itemName
local itemPrice
local itemAmount
local isWeapon

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function secondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

function DrawText3D(x,y,z, text) -- some useful function, use it if you want!
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    if onScreen then
        SetTextScale(0.5,0.5)
        SetTextFont(6)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

RegisterCommand("trader", function(source, args, rawCommand)
	
	if startTimer then
		--print("The trader will spawn in " .. newAmount .. " seconds")

		TriggerClientEvent('chat:addMessage', source, { args = { "Trader ", "The trader will spawn in " .. newAmount .. " seconds!" }, color = 255, 0, 0 })
		  
		  
	end
	
	if startNPCDuration then
		--print("The trader will go away in " .. amountOfTime .. " seconds")
		TriggerClientEvent('chat:addMessage', source, { args = { "Trader ", "The trader will leave in " .. amountOfTime .. " seconds!" }, color = 255, 0, 0 })

	end

end)	

-- Buy Event
RegisterServerEvent('snazz:buyItem')
AddEventHandler('snazz:buyItem', function(item, label, price, amount, isWeapon)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local playerName = GetPlayerName(source) 

	itemValue = item
	itemName = label
	itemPrice = ESX.Math.Round(price)
	itemAmount = amount
	isWeapon = isWeapon

	if itemPrice < 0 then
		print('[Snazz Support] ' .. xPlayer.identifier .. ' attempted to exploit the trader!')
		return
	end

	if itemAmount < 0 then
		print('[Snazz Support] ' .. xPlayer.identifier .. ' attempted to exploit the trader!')
		return
	end

	if isWeapon then

		if Config.MoneyType == 'cash' then
			if xPlayer.getMoney() >= itemPrice then
				if not xPlayer.hasWeapon(itemValue) then
					xPlayer.removeMoney(itemPrice * 1)
					xPlayer.addWeapon(itemValue, 60)

					if Config.Discord then
						sendToDiscord(65280, 'Weapon Bought','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has bought: ** ' .. itemName .. '\n**Bought for:** $' .. itemPrice .. '\n**Money Type:** Cash',"")
					end
				else
					xPlayer.showNotification('You already have this weapon!')
				end
			else
				local missingMoney = price - xPlayer.getMoney()
				xPlayer.showNotification('You do not have enough money! You need $', missingMoney)
			end
		end

		if Config.MoneyType == 'bank' then
			if xPlayer.getAccount('bank').money >= itemPrice then
				if not xPlayer.hasWeapon(itemValue) then
					xPlayer.removeAccountMoney('bank', itemPrice * 1)
					xPlayer.addWeapon(itemValue, 60)

					if Config.Discord then
						sendToDiscord(65280, 'Weapon Bought','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has bought: ** ' .. itemName .. '\n**Bought for:** $' .. itemPrice .. '\n**Money Type:** Bank',"")
					end
				else
					xPlayer.showNotification('You already have this weapon!')
				end
			else
				local missingMoney = price - xPlayer.getAccount('bank').money
				xPlayer.showNotification('You do not have enough money! You need $', missingMoney)
			end
		end

		if Config.MoneyType == 'dirty' then
			if xPlayer.getAccount('black_money').money >= itemPrice then
				if not xPlayer.hasWeapon(itemValue) then
					xPlayer.removeAccountMoney('black_money', itemPrice * 1)
					xPlayer.addWeapon(itemValue, 60)

					if Config.Discord then
						sendToDiscord(65280, 'Weapon Bought','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has bought: ** ' .. itemName .. '\n**Bought for:** $' .. itemPrice .. '\n**Money Type:** Dirty Money',"")
					end
				else
					xPlayer.showNotification('You already have this weapon!')
				end
			else
				local missingMoney = price - xPlayer.getAccount('black_money').money
				xPlayer.showNotification('You do not have enough money! You need $', missingMoney)
			end
		end

	end

	if not isWeapon then

		if Config.MoneyType == 'cash' then
			if xPlayer.getMoney() >= itemPrice then
				if xPlayer.canCarryItem(itemValue, itemAmount) then
					xPlayer.removeMoney(itemPrice * itemAmount)
					xPlayer.addInventoryItem(itemValue, itemAmount)
					
					if Config.Discord then
						sendToDiscord(65280, 'Item Bought','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has bought: ** ' .. itemName .. '\n**Amount:** x' ..  itemAmount .. '\n**Bought for:** $' .. itemPrice * itemAmount .. '\n**Money Type:** Cash',"")
					end
				else
					xPlayer.showNotification('Not enough space in your inventory!')
				end
			else
				local missingMoney = price - xPlayer.getMoney()
				xPlayer.showNotification('You do not have enough money! You need $'.. missingMoney)
			end
		end

		if Config.MoneyType == 'bank' then
			if xPlayer.getAccount('bank').money >= itemPrice then
				if xPlayer.canCarryItem(itemValue, itemAmount) then
					xPlayer.removeAccountMoney('bank', itemPrice * itemAmount)
					xPlayer.addInventoryItem(itemValue, itemAmount)
					
					if Config.Discord then
						sendToDiscord(65280, 'Item Bought','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has bought: ** ' .. itemName .. '\n**Amount:** x' ..  itemAmount .. '\n**Bought for:** $' .. itemPrice * itemAmount .. '\n**Money Type:** Bank',"")
					end
				else
					xPlayer.showNotification('Not enough space in your inventory!')
				end
			else
				local missingMoney = price - xPlayer.getAccount('bank').money
				xPlayer.showNotification('You do not have enough money! You need $'.. missingMoney)
			end
		end

		if Config.MoneyType == 'dirty' then
			if xPlayer.getAccount('black_money').money >= itemPrice then
				if xPlayer.canCarryItem(itemValue, itemAmount) then
					xPlayer.removeAccountMoney('black_money', itemPrice * itemAmount)
					xPlayer.addInventoryItem(itemValue, itemAmount)

					if Config.Discord then
						sendToDiscord(65280, 'Item Bought','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has bought: ** ' .. itemName .. '\n**Amount:** x' ..  itemAmount .. '\n**Bought for:** $' .. itemPrice * itemAmount .. '\n**Money Type:** Dirty Money',"")
					end
				else
					xPlayer.showNotification('Not enough space in your inventory!')
				end
			else
				local missingMoney = price - xPlayer.getAccount('black_money').money
				xPlayer.showNotification('You do not have enough money! You need $'.. missingMoney)
			end
		end

	end

end)

-- Sell Event
RegisterServerEvent('snazz:sellItem')
AddEventHandler('snazz:sellItem', function(item, label, price, amount, isWeapon)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local playerName = GetPlayerName(source) 

	itemValue = item
	itemName = label
	itemPrice = ESX.Math.Round(price)
	itemAmount = amount
	isWeapon = isWeapon

	if itemPrice < 0 then
		print('[Snazz Support] ' .. xPlayer.identifier .. ' attempted to exploit the trader!')
		return
	end

	if itemAmount < 0 then
		print('[Snazz Support] ' .. xPlayer.identifier .. ' attempted to exploit the trader!')
		return
	end

	if isWeapon then
		if Config.MoneyType == 'cash' then
			if xPlayer.hasWeapon(itemValue) then
				xPlayer.addAccountMoney('cash', itemPrice * 1)
				xPlayer.removeWeapon(itemValue)
			else
				xPlayer.showNotification("You don't have the weapon!")
			end

			if Config.Discord then
				sendToDiscord(65280, 'Weapon Sold','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has sold: ** ' .. itemName .. '\n**Sold for:** $' .. itemPrice .. '\n**Money Type:** Cash',"")
			end
		end

		if Config.MoneyType == 'bank' then
			if xPlayer.hasWeapon(itemValue) then
				xPlayer.addAccountMoney('bank', itemPrice * 1)
				xPlayer.removeWeapon(itemValue)
			else
				xPlayer.showNotification("You don't have the weapon!")
			end

			if Config.Discord then
				sendToDiscord(65280, 'Weapon Sold','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has sold: ** ' .. itemName .. '\n**Sold for:** $' .. itemPrice .. '\n**Money Type:** Bank',"")
			end
		end

		if Config.MoneyType == 'dirty' then
			if xPlayer.hasWeapon(itemValue) then
				xPlayer.addAccountMoney('black_money', itemPrice * 1)
				xPlayer.removeWeapon(itemValue)
			else
				xPlayer.showNotification("You don't have the weapon!")
			end

			if Config.Discord then
				sendToDiscord(65280, 'Weapon Sold','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has sold: ** ' .. itemName .. '\n**Sold for:** $' .. itemPrice .. '\n**Money Type:** Dirty Money',"")
			end
		end

	end

	if not isWeapon then

		if Config.MoneyType == 'cash' then
			if xPlayer.getInventoryItem(itemValue).count >= itemAmount then
				xPlayer.addAccountMoney('cash', itemPrice * itemAmount)
				xPlayer.removeInventoryItem(itemValue, itemAmount)
				
				if Config.Discord then
					sendToDiscord(65280, 'Item Sold','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has sold: ** ' .. itemName .. '\n**Amount:** x' ..  itemAmount .. '\n**Sold for:** $' .. itemPrice * itemAmount .. '\n**Money Type:** Cash',"")
				end
			else
				xPlayer.showNotification('You dont have the item!')
			end
		end

		if Config.MoneyType == 'bank' then
			if xPlayer.getInventoryItem(itemValue).count >= itemAmount then
				xPlayer.addAccountMoney('bank', itemPrice * itemAmount)
				xPlayer.removeInventoryItem(itemValue, itemAmount)
				
				if Config.Discord then
					sendToDiscord(65280, 'Item Sold','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has sold: ** ' .. itemName .. '\n**Amount:** x' ..  itemAmount .. '\n**Sold for:** $' .. itemPrice * itemAmount .. '\n**Money Type:** Bank',"")
				end
			else
				xPlayer.showNotification('You dont have the item!')
			end
		end

		if Config.MoneyType == 'dirty' then
			if xPlayer.getInventoryItem(itemValue).count >= itemAmount then
				xPlayer.addAccountMoney('black_money', itemPrice * itemAmount)
				xPlayer.removeInventoryItem(itemValue, itemAmount)
				
				if Config.Discord then
					sendToDiscord(65280, 'Item Sold','**Player Name:** ' .. playerName .. '\n' .. '**Player ID:** ' .. source .. '\n\n' .. '**This player has sold: ** ' .. itemName .. '\n**Amount:** x' ..  itemAmount .. '\n**Sold for:** $' .. itemPrice * itemAmount .. '\n**Money Type:** Dirty Money',"")
				end
			else
				xPlayer.showNotification('You dont have the item!')
			end
		end

	end

end)


RegisterServerEvent('snazz:startTimer')
AddEventHandler('snazz:startTimer', function()
	startTimer = true
	traderFinished = false
	timerFinished = false
	spawned = false
	locationChosen = false
	
	newAmount = Config.Trader.NPCSpawnRate
	

    while (newAmount > 0) do
		Wait(1000)
        newAmount = newAmount - 1
    end
	
	if newAmount == 0 then
		timerFinished = true
		if Config.DebugMode then
			if Config.DebugMode then
				print("[Snazz Support] Server Side: Timer Finished, moving onto NPC Spawn")
			end
		end
		startTimer = false
	end
end)

RegisterServerEvent('snazz:startNPCDuration')
AddEventHandler('snazz:startNPCDuration', function()
	startNPCDuration = true
	
	amountOfTime = Config.Trader.NPCDuration
	
	
   while (amountOfTime ~= 0) do
        Wait(1000)
        amountOfTime = amountOfTime - 1
    end
	
	if amountOfTime == 0 then
		TriggerClientEvent('snazz:deleteNPC', -1)
		traderFinished = true
		startNPCDuration = false
		
		Wait(1000)
		TriggerEvent('snazz:startTimer')
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		
		while not timerFinished do
			Wait(1)
		end
			
		while timerFinished and not traderFinished do
			Wait(1)

			if Config.DebugMode then
				if Config.DebugMode then
					print("[Snazz Support] Server Side: NPC Timer Started")
				end
			end

			if not spawned then
				local curRanPos = Config.Trader.NPCLocations[math.random(1, #Config.Trader.NPCLocations)]
				TriggerClientEvent('snazz:spawnNPC', -1, curRanPos)
				
				if Config.DebugMode then
					print("[Snazz Support] Server Side: Sent Client values to spawn NPC")
				end

				TriggerEvent('snazz:startNPCDuration')
				spawned = true
			end
			
			
		end
	end
end)

-- Start Timer
AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then	
		TriggerEvent('snazz:startTimer')
		
		if Config.DebugMode then
			print("[Snazz Support] Server Side: Resource Started Executed")
		end

		return
	end
end)