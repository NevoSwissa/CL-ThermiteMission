local QBCore = exports['qb-core']:GetCoreObject()

local StartPeds = {}

local isActive = false

local InMilitaryPoint = false

local InBuyerPoint = false

local CurrentCops = 0 

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

Citizen.CreateThread(function()
	for _, info in pairs(Config.BlipLocation) do
		if Config.UseBlips then
	   		info.blip = AddBlipForCoord(info.x, info.y, info.z)
	   		SetBlipSprite(info.blip, info.id)
	   		SetBlipDisplay(info.blip, 4)
	   		SetBlipScale(info.blip, 0.6)	
	   		SetBlipColour(info.blip, info.colour)
	   		SetBlipAsShortRange(info.blip, true)
	   		BeginTextCommandSetBlipName("STRING")
	   		AddTextComponentString(info.title)
	   		EndTextCommandSetBlipName(info.blip)
	 	end
   	end	
end)

CreateThread(function()
    for k, v in pairs(Config.StartPeds) do
        RequestModel(GetHashKey(v.Ped))
        while not HasModelLoaded(GetHashKey(v.Ped)) do
            Wait(1)
        end
        StartPed = CreatePed(0, v.Ped, v.Coords['PedCoords'].x,v.Coords['PedCoords'].y, v.Coords['PedCoords'].z, v.Coords['Heading'], false, true)
        SetEntityInvincible(StartPed, true)
        SetBlockingOfNonTemporaryEvents(StartPed, true)
        TaskStartScenarioInPlace(StartPed, v.Scenario, 0, true) 
        FreezeEntityPosition(StartPed, true)

        exports['qb-target']:AddEntityZone("Paige"..k, StartPed, {
            name = "Paige"..k,
        }, {
          options = {
            { 
                icon = v.Icon,
                label = v.Label,
                action = function()
                    StartMission()
                end,
                canInteract = function(StartPed)
                    if IsPedAPlayer(StartPed) then 
                        return false 
                    end 
                    return true
                end,
            }
          },
          distance = v.Coords['Distance'],
        })
    end
end)

local StartCoolDownRemaining = 0

function StartMission()
    if CurrentCops >= Config.RequiredPolice then
        if StartCoolDownRemaining <= 0 then
            StartCoolDown()
            TriggerServerEvent("CL-ThermiteMission:server:SetActive", true)
            TriggerServerEvent("CL-ThermiteMission:SendDiscordLog")
            SendEmail()
        else
            local minutes = math.floor(StartCoolDownRemaining / 60)
            local seconds = StartCoolDownRemaining - minutes * 60
            QBCore.Functions.Notify("You Have To Wait " .. minutes .. " Minutes And ".. seconds .. " Seconds Before Starting Robbing Again !", "error")
        end
    else
        QBCore.Functions.Notify("You need " .. Config.RequiredPolice .. " cops to start the mission")
    end
end

function StartCoolDown()
    StartCoolDownRemaining = Config.NextRob
    Citizen.CreateThread(function()
        while StartCoolDownRemaining > 0 do
            Citizen.Wait(1000)
            StartCoolDownRemaining = StartCoolDownRemaining - 1
        end
    end)
end

RegisterNetEvent("CL-ThermiteMission:SpawnTruck")
AddEventHandler("CL-ThermiteMission:SpawnTruck", function()
    local coords = vector4(-2118.253, 3284.9494, 32.432666, 150.8552)
    QBCore.Functions.SpawnVehicle("barracks", function(veh)
        SetVehicleNumberPlateText(veh, "HEIST"..tostring(math.random(1000, 9999)))
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        SetVehicleDoorsLocked(veh, true)
        Citizen.Wait(5000)
        SetVehicleDoorsLocked(veh, false)
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(7)
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    QBCore.Functions.Notify("Drive To The Location Marked On Your GPS !", "success", 4000)
                    BuyerBlip()
                    break
                end
            end
        end)
    end, coords, true)
end)

function SendEmail()
    TriggerServerEvent(Config.Phone..':server:sendNewMail', {
        sender = "Paige",
        subject = "Thermite Mission",
        message = "So You Need Some Thermite? <br /> <strong/> I Set The Location For You On The GPS </strong>",
        button = {}
    }) 
    MissionBlip()
end

function CheckCoords()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(7)
            local ped = GetPlayerPed(-1) 
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            local Distance = GetDistanceBetweenCoords(PlayerCoords, -2133.433, 3261.0524, 32.81026, true) 
            if Distance < 60.0 then
                InMilitaryPoint = true
                TriggerServerEvent("CL-ThermiteMission:Server:GuardsSync", -1)
                TriggerEvent("CL-ThermiteMission:SpawnTruck")
                QBCore.Functions.Notify("Kill The Guards !")
                break
            end
        end
    end)
end

function CheckBuyerCoords()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(7)
            local ped = GetPlayerPed(-1) 
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            local Distance = GetDistanceBetweenCoords(PlayerCoords, 1963.4307, 5160.2871, 47.196655, true) 
            local car = GetVehiclePedIsIn(PlayerPedId(),true)
            if Distance < 5.0 then
                InBuyerPoint = true
                PlayCutscene('mph_pac_con_ext')
                DeleteVehicle(car)
                DeleteEntity(car)
                Citizen.Wait(20000)
                TriggerServerEvent("QBCore:Server:AddItem", Config.ThermiteItem, math.random(Config.MinEarn,Config.MaxEarn))
                TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['thermite'], "add")
                TriggerEvent("CL-ThermiteMission:ResetMission")
                break
            end
        end
    end)
end

RegisterNetEvent("CL-ThermiteMission:ResetMission")
AddEventHandler("CL-ThermiteMission:ResetMission", function()
    StartPeds = {}
    TriggerServerEvent("CL-ThermiteMission:server:SetActive", false)
    InBuyerPoint = false
    InMilitaryPoint = false
end)

RegisterNetEvent('CL-ThermiteMission:client:SetActive', function(status)
    isActive = status
end)

function MissionBlip()
    local Mblip = AddBlipForCoord(-2133.433, 3261.0524, 32.81026)
    SetBlipSprite(Mblip, 307)
    SetBlipColour(Mblip, 0)
    SetBlipScale(Mblip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Military Base")
    EndTextCommandSetBlipName(Mblip)
    CheckCoords()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(7)
            if InMilitaryPoint == true then
                RemoveBlip(Mblip)
                TriggerServerEvent('police:server:policeAlert', 'Attempted Thermite Robbery')
                break
            end
        end
    end)
end

function BuyerBlip()
    local Bblip = AddBlipForCoord(1963.4307, 5160.2871, 47.196655)
    SetBlipSprite(Bblip, 586)
    SetBlipColour(Bblip, 4)
    SetBlipScale(Bblip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Buyer")
    EndTextCommandSetBlipName(Bblip)
    CheckBuyerCoords()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(7)
            if InBuyerPoint == true then
                RemoveBlip(Bblip)
                break
            end
        end
    end)
end

RegisterNetEvent('CL-ThermiteMission:GuardsSync', function()
    SpawnGuards()
end)

function SpawnGuards()
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, GetHashKey('PLAYER'))
    AddRelationshipGroup('GuardPeds')

    for k, v in pairs(Config.Guards) do
        RequestModel(GetHashKey(v.Ped))
        while not HasModelLoaded(GetHashKey(v.Ped)) do
            Wait(1)
        end
        Guards = CreatePed(0, GetHashKey(v.Ped), v.Coords, true, true)
        NetworkRegisterEntityAsNetworked(Guards)
        networkID = NetworkGetNetworkIdFromEntity(Guards)
        SetNetworkIdCanMigrate(networkID, true)
        GiveWeaponToPed(Guards, GetHashKey(v.Weapon), 255, false, false) 
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetEntityAsMissionEntity(Guards)
        SetPedDropsWeaponsWhenDead(Guards, false)
        SetPedRelationshipGroupHash(Guards, GetHashKey("GuardPeds"))
        SetEntityVisible(Guards, true)
        SetPedRandomComponentVariation(Guards, 0)
        SetPedRandomProps(Guards)
        SetPedCombatMovement(Guards, v.Aggresiveness)
        SetPedAlertness(Guards, v.Alertness)
        SetPedAccuracy(Guards, v.Accuracy)
        SetPedMaxHealth(Guards, v.Health)
    end

    SetRelationshipBetweenGroups(0, GetHashKey("GuardPeds"), GetHashKey("GuardPeds"))
	SetRelationshipBetweenGroups(5, GetHashKey("GuardPeds"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("GuardPeds"))
end

AddEventHandler('onResourceStop', function (resource)
    if resource == GetCurrentResourceName() then
        ClearArea(-2140.512, 3244.9045, 32.81031, 80.0)
		ClearAreaOfEverything(-2140.512, 3244.9045, 32.81031, 80.0, true, true, true, true)
    end
end)

AddEventHandler('onResourceStart', function (resource)
    if resource == GetCurrentResourceName() then
        ClearArea(-2140.512, 3244.9045, 32.81031, 80.0)
		ClearAreaOfEverything(-2140.512, 3244.9045, 32.81031, 80.0, true, true, true, true)
    end
end)

function PlayCutscene(cut)
    while not HasThisCutsceneLoaded(cut) do 
        RequestCutscene(cut, 8)
        Wait(0) 
    end
    CreateCutscene()
    RemoveCutscene()
    DoScreenFadeIn(500)
end

function CreateCutscene()
    local ped = PlayerPedId()   
    local clone = ClonePedEx(ped, 0.0, false, true, 1)
    local clone2 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone3 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone4 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone5 = ClonePedEx(ped, 0.0, false, true, 1)
    SetBlockingOfNonTemporaryEvents(clone, true)
    SetEntityVisible(clone, false, false)
    SetEntityInvincible(clone, true)
    SetEntityCollision(clone, false, false)
    FreezeEntityPosition(clone, true)
    SetPedHelmet(clone, false)
    RemovePedHelmet(clone, true) 
    SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
    RegisterEntityForCutscene(ped, 'MP_1', 0, GetEntityModel(ped), 64)
    SetCutsceneEntityStreamingFlags('MP_2', 0, 1)
    RegisterEntityForCutscene(clone2, 'MP_2', 0, GetEntityModel(clone2), 64)
    SetCutsceneEntityStreamingFlags('MP_3', 0, 1)
    RegisterEntityForCutscene(clone3, 'MP_3', 0, GetEntityModel(clone3), 64)
    SetCutsceneEntityStreamingFlags('MP_4', 0, 1)
    RegisterEntityForCutscene(clone4, 'MP_4', 0, GetEntityModel(clone4), 64)
    SetCutsceneEntityStreamingFlags('MP_5', 0, 1)
    RegisterEntityForCutscene(clone5, 'MP_5', 0, GetEntityModel(clone5), 64)
    Wait(10)
    StartCutscene(0)
    Wait(10)
    ClonePedToTarget(clone, ped)
    Wait(10)
    DeleteEntity(clone)
    DeleteEntity(clone2)
    DeleteEntity(clone3)
    DeleteEntity(clone4)
    DeleteEntity(clone5)
    Wait(50)
    DoScreenFadeIn(250)
end