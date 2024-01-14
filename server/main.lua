ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
  TriggerEvent('esx_service:activateService', 'burgershot', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'burgershot', _U('burgershot_customer'), true, true)
TriggerEvent('esx_society:registerSociety', 'burgershot', 'burgershot', 'society_burgershot', 'society_burgershot', 'society_burgershot', {type = 'private'})



RegisterServerEvent('bs_burgershotjob:getStockItem')
AddEventHandler('bs_burgershotjob:getStockItem', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_burgershot', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)

  end)

end)

RegisterServerEvent('bs_burgershotjob:Billing')
AddEventHandler('bs_burgershotjob:Billing', function(money, player)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(player)
    local valor = money

    if xTarget.getMoney() >= valor then
        xTarget.removeMoney(valor)
        xPlayer.addMoney(valor)
    else
        local message1 = _U('customer_no_money', { value = valor })
        local message2 = _U('you_have_no_money', { value = valor })

        TriggerClientEvent('esx:showNotification', xPlayer.source, message1)
        TriggerClientEvent('esx:showNotification', xTarget.source, message2)
    end
end)

ESX.RegisterServerCallback('bs_burgershotjob:getStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_burgershot', function(inventory)
    cb(inventory.items)
  end)

end)

ESX.RegisterServerCallback('bs_burgershotjob:RemoveMissionItems', function(source, cb, itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(itemName) then
		cb(true)
	else
		cb(false)
	end

end)

RegisterServerEvent('bs_burgershotjob:putStockItems')
AddEventHandler('bs_burgershotjob:putStockItems', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_burgershot', function(inventory)

    local item = inventory.getItem(itemName)
    local playerItemCount = xPlayer.getInventoryItem(itemName).count

    if item.count >= 0 and count <= playerItemCount then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)

  end)

end)

RegisterServerEvent('bs_burgershotjob:removeMoneyFromAccount')
AddEventHandler('bs_burgershotjob:removeMoneyFromAccount', function(itemName, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(itemName) and price < 65500 and xPlayer.job.name == "burgershot" then
		xPlayer.removeInventoryItem(itemName, 1)
		xPlayer.addAccountMoney("money", price)
	else
		DropPlayer(source, 'Atleast you tried lol.')
        CancelEvent()
	end
end)


RegisterServerEvent('bs_burgershotjob:getFridgeStockItem')
AddEventHandler('bs_burgershotjob:getFridgeStockItem', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_burgershot_fridge', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('bs_burgershotjob:getFridgeStockItems', function(source, cb)
  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_burgershot_fridge', function(inventory)
		if inventory ~= nil then
		cb(inventory.items)
		else
		TriggerClientEvent('esx:showNotification', source, _U('quantity_invalid'))
		end
	end)
end)

RegisterServerEvent('bs_burgershotjob:putFridgeStockItems')
AddEventHandler('bs_burgershotjob:putFridgeStockItems', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_burgershot_fridge', function(inventory)
	if inventory ~= nil then
    local item = inventory.getItem(itemName)
    local playerItemCount = xPlayer.getInventoryItem(itemName).count

    if item.count >= 0 and count <= playerItemCount then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)

	else
	
	TriggerClientEvent('esx:showNotification', source, _U('quantity_invalid'))
	
	end
  end)

end)


RegisterServerEvent('bs_burgershotjob:buyItem')
AddEventHandler('bs_burgershotjob:buyItem', function(itemName, price, itemLabel)
	print(itemName, price, itemLabel)
    local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    local limit = xPlayer.getInventoryItem(itemName).limit
    local qtty = xPlayer.getInventoryItem(itemName).count
    local societyAccount = nil

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_burgershot', function(account)
        societyAccount = account
      end)
    
    if societyAccount ~= nil and societyAccount.money >= price then
        if qtty < limit then
            societyAccount.removeMoney(price)
            xPlayer.addInventoryItem(itemName, 1)
            TriggerClientEvent('esx:showNotification', _source, _U('bought') .. itemLabel)
        else
            TriggerClientEvent('esx:showNotification', _source, _U('max_item'))
        end
    else
        TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
    end

end)

RegisterServerEvent('bs_burgershotjob:craftingCoktails')
AddEventHandler('bs_burgershotjob:craftingCoktails', function(Value)
    local _source = source
    local escolha = Value

    if escolha == "shamburger" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('ccheese').count
        local bethQuantity  = xPlayer.getInventoryItem('fburger').count
        local gammaQuantity = xPlayer.getInventoryItem('bread').count

        if alephQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_chopped_tomatoes'))
        elseif bethQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_frozen_beef_patties'))
        elseif gammaQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_bread'))
        else
            TriggerClientEvent('esx:showNotification', _source, _U('cooked_simple_bun_burger'))
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(20000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('made_simple_burger'))
            xPlayer.removeInventoryItem('ccheese', 1)
            xPlayer.removeInventoryItem('fburger', 1)
            xPlayer.removeInventoryItem('bread', 1)
            xPlayer.addInventoryItem('shamburger', 1)
        end
    elseif escolha == "hamburger" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('ccheese').count
        local bethQuantity  = xPlayer.getInventoryItem('ctomato').count
        local bethQuantity2 = xPlayer.getInventoryItem('clettuce').count
        local gammaQuantity = xPlayer.getInventoryItem('fburger').count
        local gammaQuantity2 = xPlayer.getInventoryItem('bread').count

        if alephQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_cheese'))
        elseif bethQuantity < 2 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_tomatoes'))
        elseif bethQuantity2 < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_lettuce'))
        elseif gammaQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_frozen_burgers'))
        elseif gammaQuantity2 < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_bread'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(25000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)

            TriggerClientEvent('esx:showNotification', _source, _U('made_burger'))
            xPlayer.removeInventoryItem('ccheese', 1)
            xPlayer.removeInventoryItem('ctomato', 2)
            xPlayer.removeInventoryItem('clettuce', 1)
            xPlayer.removeInventoryItem('fburger', 1)
            xPlayer.removeInventoryItem('bread', 1)
            xPlayer.addInventoryItem('hamburger', 1)
        end
    elseif escolha == "vhamburger" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('ctomato').count
        local bethQuantity  = xPlayer.getInventoryItem('clettuce').count
        local bethQuantity2 = xPlayer.getInventoryItem('fvburger').count
        local bethQuantity3 = xPlayer.getInventoryItem('vbread').count

        if alephQuantity < 2 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_tomatoes'))
        elseif bethQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_lettuce'))
        elseif bethQuantity2 < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_frozen_veggie_burgers'))
        elseif bethQuantity2 < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_gluten_free_bread'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(25000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('made_veggie_burger'))
            xPlayer.removeInventoryItem('ctomato', 2)
            xPlayer.removeInventoryItem('clettuce', 1)
            xPlayer.removeInventoryItem('fvburger', 1)
            xPlayer.removeInventoryItem('vbread', 1)
            xPlayer.addInventoryItem('vhamburger', 1)
        end
    elseif escolha == "nuggets4" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('nugget').count

        if alephQuantity < 4 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_chicken_nuggets'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(20000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('cooked_four_chicken_nuggets'))
            xPlayer.removeInventoryItem('nugget', 4)
            xPlayer.addInventoryItem('nuggets4', 1)
        end
    elseif escolha == "nuggets10" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('nugget').count
        if alephQuantity < 10 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_chicken_nuggets'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(20000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('made_ten_chicken_nuggets'))
            xPlayer.removeInventoryItem('nugget', 10)
            xPlayer.addInventoryItem('nuggets10', 1)
        end
    elseif escolha == "chips" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('potato').count

        if alephQuantity < 2 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_potatoes'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(20000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('made_large_fries'))
            xPlayer.removeInventoryItem('potato', 2)
            xPlayer.addInventoryItem('chips', 1)
        end
    elseif escolha == "ctomato" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('tomato').count

        if alephQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_tomatoes'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(15000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', __source, _U('sliced_tomato'))
            xPlayer.removeInventoryItem('tomato', 1)
            xPlayer.addInventoryItem('ctomato', 4)
        end
    elseif escolha == "clettuce" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('lettuce').count

        if alephQuantity < 2 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_lettuce'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(15000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('sliced_lettuce'))
            xPlayer.removeInventoryItem('lettuce', 1)
            xPlayer.addInventoryItem('clettuce', 4)
        end
    elseif escolha == "ccheese" then
        local xPlayer       = ESX.GetPlayerFromId(_source)
        local alephQuantity = xPlayer.getInventoryItem('cheese').count

        if alephQuantity < 1 then
            TriggerClientEvent('esx:showNotification', _source, _U('need_more_cheese'))
        else
            TriggerClientEvent('esx_burgershot:StartCookAnimation', _source)
            Citizen.Wait(15000)
            TriggerClientEvent('esx_burgershot:StopCookAnimation', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('sliced_cheese'))
            xPlayer.removeInventoryItem('cheese', 1)
            xPlayer.addInventoryItem('ccheese', 5)
        end
    else
        TriggerClientEvent('esx:showNotification', _source, "~r~ERRO 404~w~")
    end
end)



RegisterServerEvent('bs_burgershotjob:shop')
AddEventHandler('bs_burgershotjob:shop', function(item, valor)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getMoney() > valor then
        xPlayer.removeMoney(valor)
        xPlayer.addInventoryItem(item, 1)
	end
end)

ESX.RegisterServerCallback('bs_burgershotjob:getVaultWeapons', function(source, cb)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_burgershot', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    cb(weapons)

  end)

end)

ESX.RegisterServerCallback('bs_burgershotjob:addVaultWeapon', function(source, cb, weaponName)

  local xPlayer = ESX.GetPlayerFromId(source)

  xPlayer.removeWeapon(weaponName)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_burgershot', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    local foundWeapon = false

    for i=1, #weapons, 1 do
      if weapons[i].name == weaponName then
        weapons[i].count = weapons[i].count + 1
        foundWeapon = true
      end
    end

    if not foundWeapon then
      table.insert(weapons, {
        name  = weaponName,
        count = 1
      })
    end

     store.set('weapons', weapons)

     cb()

  end)

end)

ESX.RegisterServerCallback('bs_burgershotjob:removeVaultWeapon', function(source, cb, weaponName)

  local xPlayer = ESX.GetPlayerFromId(source)

  xPlayer.addWeapon(weaponName, 1000)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_burgershot', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    local foundWeapon = false

    for i=1, #weapons, 1 do
      if weapons[i].name == weaponName then
        weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
        foundWeapon = true
      end
    end

    if not foundWeapon then
      table.insert(weapons, {
        name  = weaponName,
        count = 0
      })
    end

     store.set('weapons', weapons)

     cb()

  end)

end)

ESX.RegisterServerCallback('bs_burgershotjob:getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local items      = xPlayer.inventory

  cb({
    items      = items
  })

end)
