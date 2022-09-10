Config = Config or {}

Config.LogsImage = "https://cdn.discordapp.com/attachments/926465631770005514/966038265130008576/CloudDevv.png"

Config.WebHook = "https://discord.com/api/webhooks/960218826815979610/XoZQIu9DCQIDzxBZ76uUf4zDoabyFGRfWc7UM_CxrgOBId2mFCT1qzY6zU-XzNkIkW19"

Config.RequiredPolice = 0 -- Needed cops to start the mission

Config.PoliceJob = 'police' -- Police job

Config.UseBlips = true

Config.Phone = 'qb-phone'

Config.ThermiteItem = 'thermite'

Config.MinEarn = 7

Config.MaxEarn = 10

Config.NextRob = 8 -- Time player can start the mission again (in seconds)

Config.StartPeds = {  -- Start ped locations + model
    [1] = {
        Scenario = "WORLD_HUMAN_CLIPBOARD", -- Scenario for the ped, more can be found at : https://wiki.rage.mp/index.php?title=Scenarios
        Icon = "fas fa-box", -- Icon for the target
        Label = "Start Thermite Mission", -- Label for the target
        Ped = "csb_paige", -- Ped more can be found : https://docs.fivem.net/docs/game-references/ped-models/
        Coords = { -- Coords table  
            PedCoords = vector3(-604.0787, -773.9486, 24.403778), -- Main coords for the ped vector3 format always
            Heading = 189.80155, -- Heading for the ped
            Distance = 2.0, -- Distance to interact with the ped
        },
    },
}

Config.BlipLocation = {
    {title = "Paige", colour = 0, id = 47, x = -604.0787, y = -773.9486, z = 25.403778},
}

Config.Guards = {
    [1] = {
        Coords = vector4(-2147.055, 3247.2202, 32.810306, 130.6092),
        Ped = 's_m_y_blackops_01',
        Weapon = 'WEAPON_CARBINERIFLE',
        Health = 3000,
        Accuracy = 60,
        Alertness = 3,
        Aggresiveness = 3,
    },
    [2] = {
        Coords = vector4(-2121.281, 3265.7536, 32.80957, 159.09059),
        Ped = 's_m_y_blackops_01',
        Weapon = 'WEAPON_CARBINERIFLE',
        Health = 3000,
        Accuracy = 60,
        Alertness = 3,
        Aggresiveness = 3,
    },
    [3] = {
        Coords = vector4(-2099.775, 3267.1691, 32.812232, 133.71133),
        Ped = 's_m_y_blackops_01',
        Weapon = 'WEAPON_CARBINERIFLE',
        Health = 3000,
        Accuracy = 60,
        Alertness = 3,
        Aggresiveness = 3,
    },
    [4] = {
        Coords = vector4(-2092.431, 3278.4438, 32.804031, 133.92941),
        Ped = 's_m_y_blackops_01',
        Weapon = 'WEAPON_CARBINERIFLE',
        Health = 3000,
        Accuracy = 60,
        Alertness = 3,
        Aggresiveness = 3,
    },
    [5] = {
        Coords = vector4(-2109.844, 3277.0988, 38.732337, 149.50251),
        Ped = 's_m_y_blackops_01',
        Weapon = 'WEAPON_CARBINERIFLE',
        Health = 3000,
        Accuracy = 60,
        Alertness = 3,
        Aggresiveness = 3,
    },
    [6] = {
        Coords = vector4(-2133.197, 3290.2985, 38.726982, 139.82868),
        Ped = 's_m_y_blackops_01',
        Weapon = 'WEAPON_CARBINERIFLE',
        Health = 3000,
        Accuracy = 60,
        Alertness = 3,
        Aggresiveness = 3,
    },
}