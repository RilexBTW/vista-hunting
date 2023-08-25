local QBCore = exports['qb-core']:GetCoreObject()

--[[local carcasses = {
    { name = "huntingcarcass1", price = 100, illegal = false },
    { name = "huntingcarcass2", price = 175, illegal = false },
    { name = "huntingcarcass3", price = 225, illegal = false },
    { name = "huntingcarcass4", price = 300, illegal = true },
} ]]

RegisterNetEvent('qb-hunting:client:sell', function ()
  TriggerServerEvent("qb-hunting:server:sell")
end)

RegisterNetEvent('qb-hunting:client:sellDirty', function()
  TriggerServerEvent('qb-hunting:server:sellDirty')
end)
