local QBCore = exports['qb-core']:GetCoreObject()

exports.ox_inventory:RegisterShop('hunting', {
  name = 'Hunting Shop',
  inventory = {
    { name = 'WEAPON_SNIPERRIFLE', price = 2500 },
    { name = 'huntingbait', price = 20 },
    { name = 'ammo-sniper', price = 10 },
    { name = 'weapon_knife', price = 250},
},
  locations = {
    vector3(-679.16, 5834.47, 16.33),
  }
})

RegisterServerEvent('qb-hunting:skinReward')
AddEventHandler('qb-hunting:skinReward', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local randomAmount = math.random(1,30)
  
  if randomAmount > 1 and randomAmount < 15 then
    Player.Functions.AddItem("huntingcarcass1", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["huntingcarcass1"], "add")
  elseif randomAmount > 15 and randomAmount < 23 then
    Player.Functions.AddItem("huntingcarcass2", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["huntingcarcass2"], "add")
  elseif randomAmount > 23 and randomAmount < 29 then
    Player.Functions.AddItem("huntingcarcass3", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["huntingcarcass3"], "add")
  else
    Player.Functions.AddItem("huntingcarcass3", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["huntingcarcass3"], "add")
  end
end)


RegisterServerEvent('qb-hunting:dirtyMoneyReward')
AddEventHandler('qb-hunting:dirtyMoneyReward', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem("huntingcarcass4", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["huntingcarcass4"], "add")
end)

RegisterServerEvent('qb-hunting:removeBait')
AddEventHandler('qb-hunting:removeBait', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  Player.Functions.RemoveItem("huntingbait", 1)
end)

RegisterServerEvent('remove:money')
AddEventHandler('remove:money', function(totalCash)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)

  if Player.PlayerData.money['cash'] >= (500) then
    Player.Functions.RemoveMoney('cash', 500)
    TriggerClientEvent("qb-hunting:setammo", src)
    TriggerClientEvent("QBCore:Notify", src, 'Reloaded.')
  else
    TriggerClientEvent("QBCore:Notify", src, 'Not enough cash on you.', 'error')
  end
end)

QBCore.Functions.CreateUseableItem("huntingbait", function(source, item)
  local Player = QBCore.Functions.GetPlayer(source)

  TriggerClientEvent('qb-hunting:usedBait', source)
end)


local carcasses = {
  huntingcarcass1 = { price = 200, legal = true },
  huntingcarcass2 = { price = 475, legal = true },
  huntingcarcass3 = { price = 725, legal = true },
  huntingcarcass4 = { price = 1000, legal = false }
}

RegisterServerEvent('qb-hunting:server:sell')
AddEventHandler('qb-hunting:server:sell', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for k,v in pairs(carcasses) do
        local item = Player.Functions.GetItemByName(k)
        if item ~= nil then
            local reward = v.price * item.amount
            if not v.legal then
              QBCore.Functions.Notify(source, "Hey Bucko, I can't accept things like that! Take these somewhere else!", 'error')
            else
                Player.Functions.RemoveItem(k, item.amount)
                Player.Functions.AddMoney('cash', reward)
            end
        end
    end
end)


RegisterServerEvent('qb-hunting:server:sellDirty')
AddEventHandler('qb-hunting:server:sellDirty', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasIllegalItems = false -- Flag to track if illegal items were found

    for k, v in pairs(carcasses) do
        local item = Player.Functions.GetItemByName(k)
        if item ~= nil and not v.legal then -- Check if the item is illegal
            local reward = v.price * item.amount
            Player.Functions.RemoveItem(k, item.amount)
            exports.ox_inventory:AddItem(source, 'black_money', reward)
        else
            hasIllegalItems = true
        end
    end

    if hasIllegalItems then
        QBCore.Functions.Notify(source, "Hey Bucko, come talk to me when you have what I'm looking for!", 'error')
    end
end)
