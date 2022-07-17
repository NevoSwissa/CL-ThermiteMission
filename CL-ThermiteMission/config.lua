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

Config.NextRob = 1200 -- Time player can start the mission again (in seconds)

Config.StartPeds = {  -- Start ped locations + model
    peds = {
        {pos = vector3(-604.0787, -773.9486, 25.403778), heading = 189.80155, ped = 'ig_paige'},
    }
}

Config.BlipLocation = {
    {title = "Paige", colour = 0, id = 47, x = -604.0787, y = -773.9486, z = 25.403778},
}

Config.Guards = {
    [1] = {
        ['pos'] = vector4(-2147.055, 3247.2202, 32.810306, 130.6092),
        ['ped'] = 's_m_y_blackops_01',
        ['weapon'] = 'WEAPON_CARBINERIFLE',
        ['health'] = 3000,
        ['accuracy'] = 60,
        ['alertness'] = 3,
        ['aggresiveness'] = 3,
    },
    [2] = {
        ['pos'] = vector4(-2121.281, 3265.7536, 32.80957, 159.09059),
        ['ped'] = 's_m_y_blackops_01',
        ['weapon'] = 'WEAPON_CARBINERIFLE',
        ['health'] = 3000,
        ['accuracy'] = 60,
        ['alertness'] = 3,
        ['aggresiveness'] = 3,
    },
    [3] = {
        ['pos'] = vector4(-2099.775, 3267.1691, 32.812232, 133.71133),
        ['ped'] = 's_m_y_blackops_01',
        ['weapon'] = 'WEAPON_CARBINERIFLE',
        ['health'] = 3000,
        ['accuracy'] = 60,
        ['alertness'] = 3,
        ['aggresiveness'] = 3,
    },
    [4] = {
        ['pos'] = vector4(-2092.431, 3278.4438, 32.804031, 133.92941),
        ['ped'] = 's_m_y_blackops_01',
        ['weapon'] = 'WEAPON_CARBINERIFLE',
        ['health'] = 3000,
        ['accuracy'] = 60,
        ['alertness'] = 3,
        ['aggresiveness'] = 3,
    },
    [5] = {
        ['pos'] = vector4(-2109.844, 3277.0988, 38.732337, 149.50251),
        ['ped'] = 's_m_y_blackops_01',
        ['weapon'] = 'WEAPON_CARBINERIFLE',
        ['health'] = 3000,
        ['accuracy'] = 60,
        ['alertness'] = 3,
        ['aggresiveness'] = 3,
    },
    [6] = {
        ['pos'] = vector4(-2133.197, 3290.2985, 38.726982, 139.82868),
        ['ped'] = 's_m_y_blackops_01',
        ['weapon'] = 'WEAPON_CARBINERIFLE',
        ['health'] = 3000,
        ['accuracy'] = 60,
        ['alertness'] = 3,
        ['aggresiveness'] = 3,
    },
}