local function sendPopulation(target)
    local players = #GetPlayers()
    local maxPlayers = GetConvarInt('sv_maxClients', 48)

    TriggerClientEvent('hydro_richpresence:population', target or -1, players, maxPlayers)
end

local refreshPending = false

local function schedulePopulationRefresh()
    if refreshPending then
        return
    end

    refreshPending = true
    SetTimeout(750, function()
        refreshPending = false
        sendPopulation()
    end)
end

RegisterNetEvent('hydro_richpresence:requestPopulation', function()
    sendPopulation(source)
end)

AddEventHandler('playerJoining', schedulePopulationRefresh)
AddEventHandler('playerDropped', schedulePopulationRefresh)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetTimeout(1000, sendPopulation)
    end
end)

CreateThread(function()
    while true do
        Wait(Config.populationRefreshInterval)
        sendPopulation()
    end
end)