local QBCore = exports['qb-core']:GetCoreObject()
local cooldown = 0
local used = false
local jobSpawned = false
local refreshPed = false
local jobPed
local useBaitCooldown = 3
local illegalhunting = false
local baitAnimal = nil
local lastCreatedAnimal = nil -- Initialize the variable to store the last created animal


local HuntingZones = {
  [1] = { label = "Hunting Zone", radius = 250.0, coords = vector3(-510.03, 4936.14, 147.32) },
  -- Add more hunting zones as needed
}

local HuntingAnimals = {
  'a_c_boar',
  'a_c_deer',
  'a_c_coyote',
  'a_c_mtlion',
}

Citizen.CreateThread(function()
  for _, zone in pairs(HuntingZones) do
    local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 2) -- Choose your desired blip color (2 is green, you can change it)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(zone.label)
    EndTextCommandSetBlipName(blip)
    
    -- Draw the blip's radius on the map
    local areaBlip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
    SetBlipColour(areaBlip, 2) -- Use the same blip color
    SetBlipAlpha(areaBlip, 100) -- Adjust the transparency of the radius on the map
  end
end)


Citizen.CreateThread(function()
  local blip = AddBlipForCoord(vector3(-679.89, 5838.79, 16.33))
  SetBlipSprite(blip, 141)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, 0.8)
  SetBlipColour(blip, 1)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Hunting Shop")
  EndTextCommandSetBlipName(blip)
  
  -- Blip for Sell Hunting Goods
  blip = AddBlipForCoord(vector3(-260.43, 2203.08, 130.1))
  SetBlipSprite(blip, 108)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, 0.8)
  SetBlipColour(blip, 44)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Sell Hunting Goods")
  EndTextCommandSetBlipName(blip)


  
  local legalHunts = {
    `a_c_boar`,
    `a_c_deer`,
    `a_c_coyote`,
    `a_c_mtlion`,
  }

  local illlegalHunts = {
    `a_c_chop`,
    `a_c_husky`,
    `a_c_retriever`,
    `a_c_westy`,
    `a_c_shepherd`,
    `a_c_poodle`,
    `u_m_y_gunvend_01`,
  }

	exports['qb-target']:AddTargetModel(legalHunts, {
    options = {
      {
        event = "qb-hunting:startskinAnimal",
        icon = "far fa-hand-paper",
        label = "Skin",
      },
    },
    distance = 1.5
  })
  
  SetScenarioTypeEnabled('WORLD_DEER_GRAZING',false)
  SetScenarioTypeEnabled('WORLD_COYOTE_WANDER',false)
  SetScenarioTypeEnabled('WORLD_COYOTE_REST',false)
  --SetScenarioTypeEnabled('WORLD_RABBIT_EATING',false)
  SetScenarioTypeEnabled('WORLD_BOAR_GRAZING',false)
  SetScenarioTypeEnabled('WORLD_MOUNTAIN_LION_WANDER',false)
  SetScenarioTypeEnabled('WORLD_MOUNTAIN_LION_REST',false)
end)


function IsInHuntingArea()
  local playerCoords = GetEntityCoords(PlayerPedId())
  for _, zone in ipairs(HuntingZones) do
    local distance = #(playerCoords - zone.coords)
    if distance <= zone.radius then
      return true
    end
  end
  return false
end



RegisterNetEvent('qb-hunting:spawnAnimal')
AddEventHandler('qb-hunting:spawnAnimal', function()
  local ped = PlayerPedId()
  local coords = GetEntityCoords(ped)
  local radius = 100.0
  local x = coords.x + math.random(-radius, radius)
  local y = coords.y + math.random(-radius, radius)
  local safeCoord, outPosition = GetSafeCoordForPed(x, y, coords.z, false, 16)
  local animal = HuntingAnimals[math.random(#HuntingAnimals)]
  local hash = GetHashKey(animal)
  
  if not HasModelLoaded(hash) then
    RequestModel(hash)
    Wait(10)
  end
  
  while not HasModelLoaded(hash) do
    Wait(10)
  end
  
  if outPosition.x > 1 or outPosition.x < -1 then
    Wait(8000)
    baitAnimal = CreatePed(28, hash, outPosition.x, outPosition.y, outPosition.z, 0, true, false)
    
    if DoesEntityExist(baitAnimal) then
      local blip = AddBlipForEntity(baitAnimal)
      SetBlipSprite(blip, 141)
      SetBlipDisplay(blip, 2)
      SetBlipColour(blip, 1)
      SetBlipAsShortRange(blip, true)
      
      TaskGoToCoordAnyMeans(baitAnimal, coords, 2.0, 0, 786603, 0)
    end
    
  else
    print('Debug: Too Far to Spawn')
    QBCore.Functions.Notify('you lost a bait because it\'s too far from the zone. Learn from your mistake :(')
  end
end)

RegisterNetEvent('qb-hunting:skinAnimal')
AddEventHandler('qb-hunting:skinAnimal', function()
  if baitAnimal ~= nil and DoesEntityExist(baitAnimal) then
    local entityModel = GetEntityModel(baitAnimal)
    print(GetHashKey('a_c_mtlion'))
    print(entityModel)
    if entityModel == GetHashKey("a_c_mtlion") then
      DeleteEntity(baitAnimal)
      TriggerServerEvent('qb-hunting:dirtyMoneyReward') -- It's a mountain lion
    else
      DeleteEntity(baitAnimal)
      TriggerServerEvent('qb-hunting:skinReward') -- It's not a mountain lion
    end
  else
    print("No valid animal entity to skin")
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)
    if DoesEntityExist(baitAnimal) then
      local ped = PlayerPedId()
      local coords = GetEntityCoords(PlayerPedId())
      local animalCoords = GetEntityCoords(baitAnimal)
      local dst = #(coords - animalCoords)
      HideHudComponentThisFrame(14)
      if dst < 2.5 then -- spook animal
        TaskCombatPed(baitAnimal,ped,0,16)
      end
    end
  end
end)


RegisterNetEvent('qb-hunting:startskinAnimal')
AddEventHandler('qb-hunting:startskinAnimal', function()
  if DoesEntityExist(baitAnimal) then
    LoadAnimDict('amb@medic@standing@kneel@base')
    LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
    
    TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, -1, 48, 0, false, false, false)
    
    QBCore.Functions.Progressbar('name_here', 'Skinning Animal...', 5000, false, true, {
      disableMovement = true,
      disableCarMovement = true,
      disableMouse = false,
      disableCombat = true,
    }, {
      animDict = '',
      anim = '',
      flags = 16,
    }, {}, {}, function() -- Play When Done
      ClearPedTasksImmediately(PlayerPedId())
      
      if IsEntityDead(baitAnimal) then
        print(baitAnimal)
        IsDrilling = false
        TriggerEvent('qb-hunting:skinAnimal')
      else
        QBCore.Functions.Notify("The animal is not dead yet. Cannot skin.", 'error')
      end
    end, function() -- Play When Cancel
      ClearPedTasksImmediately(PlayerPedId())
    end)
  else
    QBCore.Functions.Notify('This is not your kill. Move on Bucko', 'error')
  end
end)


RegisterNetEvent('qb-hunting:usedBait')
AddEventHandler('qb-hunting:usedBait', function()
    if IsInHuntingArea() and cooldown <= 0 then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            QBCore.Functions.Notify('You can\'t use that in a vehicle', 'error')
        else
            LoadAnimDict('amb@medic@standing@kneel@base')
            TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
            QBCore.Functions.Progressbar('name_here', 'Placing Bait ...', 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = '',
                anim = '',
                flags = 16,
            }, {}, {}, function() -- Play When Done
                Citizen.Wait(100)
                cooldown = useBaitCooldown * 5000
                baitCooldown()
                used = true
                usedBait()
                TriggerServerEvent('qb-hunting:removeBait')
                ClearPedTasksImmediately(PlayerPedId())
                IsDrilling = false
            end, function() -- Play When Cancel
                ClearPedTasksImmediately(PlayerPedId())
            end)
        end
    else
        TriggerEvent("QBCore:Notify", "You aren't in a hunting area!", 'alert')
    end
end)


function baitCooldown()
  Citizen.CreateThread(function()
    while cooldown > 0 do
      Wait(2000)
      cooldown = cooldown - 1000
    end
  end)
end

function usedBait()
  Citizen.CreateThread(function()
    while used do
      print('waiting to spawn')
      Wait(1500)
      print('spawning')
      TriggerEvent('qb-hunting:spawnAnimal')
      used = false
    end
  end)
end


function LoadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
    RequestAnimDict(dict)
    Citizen.Wait(10)
  end
end
