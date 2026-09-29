local population = 0
local maxPopulation = 0
local lastPresence = nil

local function trim(value)
    return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function shorten(value, limit)
    value = trim(tostring(value or ''))
    if #value > limit then
        return value:sub(1, limit - 3) .. '...'
    end
    return value
end

local function getLocation(ped)
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetHash)
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))

    if street and street ~= '' and street ~= 'NULL' then
        return street
    end

    if not zone or zone == '' or zone == 'NULL' then
        zone = 'San Andreas'
    end

    return zone
end

local function buildPresence()
    local ped = PlayerPedId()
    local location = Config.showLocation and getLocation(ped) or nil
    local details = ''
    local state

    if Config.showPopulation and maxPopulation > 0 then
        details = ('%d/%d Active'):format(population, maxPopulation)
    end

    if Config.showPlayerId then
        local playerId = ('Player ID: %d'):format(GetPlayerServerId(PlayerId()))
        details = details == '' and playerId or ('%s | %s'):format(details, playerId)
    end

    if IsEntityDead(ped) then
        state = 'Down and awaiting medical attention'
    elseif Config.showWhenPaused and IsPauseMenuActive() then
        state = 'Taking a moment away'
    elseif IsPedInAnyVehicle(ped, false) then
        state = location and ('Driving on %s'):format(location) or 'Driving'
    else
        state = location and ('Standing on %s'):format(location) or 'Standing'
    end

    return shorten(details, 44), shorten(state, 64)
end

local function applyPresence(force)
    local details, state = buildPresence()
    local combined = shorten(state .. '\n' .. details, 128)
    if not force and combined == lastPresence then
        return
    end

    lastPresence = combined
    SetRichPresence(combined)
    SetDiscordRichPresenceAsset(Config.Discord.largeAsset)
    SetDiscordRichPresenceAssetText(Config.Discord.largeAssetText)

    if Config.Discord.smallAsset and Config.Discord.smallAsset ~= '' then
        SetDiscordRichPresenceAssetSmall(Config.Discord.smallAsset)
        SetDiscordRichPresenceAssetSmallText(Config.Discord.smallAssetText)
    end
end

local function configureDiscord()
    local appId = Config.Discord.appId
    if not appId or appId == '' or appId == 'YOUR_DISCORD_APPLICATION_ID' then
        print('^3[hydro_richpresence] Set Config.Discord.appId in config.lua to enable Discord Rich Presence.^7')
        return false
    end

    SetDiscordAppId(appId)

    for index, button in ipairs(Config.Discord.buttons or {}) do
        if index > 2 then
            break
        end
        SetDiscordRichPresenceAction(index - 1, button.label, button.url)
    end

    return true
end

RegisterNetEvent('hydro_richpresence:population', function(players, maxPlayers)
    population = tonumber(players) or 0
    maxPopulation = tonumber(maxPlayers) or 0
    applyPresence(false)
end)

CreateThread(function()
    if not configureDiscord() then
        return
    end

    TriggerServerEvent('hydro_richpresence:requestPopulation')
    applyPresence(true)

    while true do
        Wait(Config.refreshInterval)
        applyPresence(false)
    end
end)