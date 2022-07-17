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

Citizen.CreateThread(function()
    for k, v in pairs(Config.StartPeds['peds']) do
        loadModel(v['ped'])
        StartPeds[k] = CreatePed(4, GetHashKey(v['ped']), v['pos']['x'], v['pos']['y'], v['pos']['z'] - 0.95, v['heading'], false, true)
        TaskStartScenarioInPlace(StartPeds[k], 'WORLD_HUMAN_CLIPBOARD', 0, false)
        FreezeEntityPosition(StartPeds[k], true)
        SetEntityInvincible(StartPeds[k], true)
        SetBlockingOfNonTemporaryEvents(StartPeds[k], true)
    end
end)

Citizen.CreateThread(function()
    while true do
        local Ped = PlayerPedId()
        local pedCo = GetEntityCoords(Ped)
        local letSleep = 1000
        local Distance = #(pedCo - vector3(-604.0787, -773.9486, 25.403778))
        if Distance <= 2.0 then
            letSleep = 1
            ShowHelpText('Press ~INPUT_PICKUP~ To Start The Thermite Mission')
            if IsControlJustPressed(0, 38) then
                StartMission()
            end
        end
        Citizen.Wait(letSleep)
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
            Wait(5000)
            TriggerServerEvent('police:server:policeAlert', 'Attempted Thermite Robbery')
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
        loadModel(v['ped'])
        Config.Guards[k] = CreatePed(26, GetHashKey(v['ped']), v['pos'], true, true)
        NetworkRegisterEntityAsNetworked(Config.Guards[k])
        networkID = NetworkGetNetworkIdFromEntity(Config.Guards[k])
        SetNetworkIdCanMigrate(networkID, true)
        GiveWeaponToPed(Config.Guards[k], GetHashKey(v['weapon']), 255, false, false) 
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetEntityAsMissionEntity(Config.Guards[k])
        SetPedDropsWeaponsWhenDead(Config.Guards[k], false)
        SetPedRelationshipGroupHash(Config.Guards[k], GetHashKey("GuardPeds"))
        SetEntityVisible(Config.Guards[k], true)
        SetPedRandomComponentVariation(Config.Guards[k], 0)
        SetPedRandomProps(Config.Guards[k])
        SetPedCombatMovement(Config.Guards[k], v['aggresiveness'])
        SetPedAlertness(Config.Guards[k], v['alertness'])
        SetPedAccuracy(Config.Guards[k], v['accuracy'])
        SetPedMaxHealth(Config.Guards[k], v['health'])
    end

    SetRelationshipBetweenGroups(0, GetHashKey("GuardPeds"), GetHashKey("GuardPeds"))
	SetRelationshipBetweenGroups(5, GetHashKey("GuardPeds"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("GuardPeds"))
end

function ShowHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, 50)
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
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