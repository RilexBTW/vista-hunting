local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-hunting:client:openHuntingShop', function()
  exports.ox_inventory:openInventory('shop', { type = 'hunting', id = 1 })
end)


Citizen.CreateThread(function()

  Citizen.Wait(500)

    RequestModel("cs_hunter")
    while not HasModelLoaded("cs_hunter") do
        Wait(500)
    end
    local ped =  CreatePed(0, 'cs_hunter', Config.PedsCoords[1].coords.x, Config.PedsCoords[1].coords.y, Config.PedsCoords[1].coords.z, Config.PedsCoords[1].heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_AA_SMOKE', true)

    exports['qb-target']:AddBoxZone("pedshop1", Config.PedsCoords[1].coords, 1.0, 1.2, {
    name = "pedshop1",
    heading=45,
    debugPoly = Config.debug,
    minZ=16.53,
    maxZ=18.33,
  }, {
    options = {
      { 
        num = 1,
        type = "client",
        event = 'qb-hunting:client:openHuntingShop',
        icon = 'fas fa-shopping-basket ',
        label = 'Hunting Shop',
      }
    },
    distance = 2.0,
  })
end)

Citizen.CreateThread(function()

  Citizen.Wait(500)
  
    RequestModel("ig_old_man2")
    while not HasModelLoaded("ig_old_man2") do
        Wait(500)
    end

    local ped =  CreatePed(0, 'ig_old_man2', Config.PedsCoords[3].coords.x, Config.PedsCoords[3].coords.y, Config.PedsCoords[3].coords.z, Config.PedsCoords[3].heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_AA_SMOKE', true)


    exports['qb-target']:AddBoxZone("pedshop3", Config.PedsCoords[3].coords, 1, 1, {
    name = "pedshop3",
    heading=0,
    debugPoly = Config.debug,
    minZ=41.3,
    maxZ=42.9,
  }, {
    options = {
      { 
        num = 1,
        type = "client",
        event = "qb-hunting:client:sellDirty",
        icon = 'fas fa-shopping-basket ',
        label = 'Sell to Illegal Trapper',
      }
    },
    distance = 1.5,
  })
end)



Citizen.CreateThread(function()

  Citizen.Wait(500)
  
    RequestModel("cs_josef")
    while not HasModelLoaded("cs_josef") do
        Wait(500)
    end

    local ped =  CreatePed(0, 'cs_josef', Config.PedsCoords[2].coords.x, Config.PedsCoords[2].coords.y, Config.PedsCoords[2].coords.z, Config.PedsCoords[2].heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_AA_SMOKE', true)


    exports['qb-target']:AddBoxZone("pedshop2", Config.PedsCoords[2].coords, 1, 1, {
    name = "pedshop2",
    heading=0,
    debugPoly = Config.debug,
    minZ=41.3,
    maxZ=42.9,
  }, {
    options = {
      { 
        num = 1,
        type = "client",
        event = "qb-hunting:client:sell",
        icon = 'fas fa-shopping-basket ',
        label = 'sell',
      }
    },
    distance = 1.5,
  })
end)