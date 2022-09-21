ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent("mn-keyAnticheat:server:registerScript", GetCurrentResourceName(), function(key) SecretKey = key end)

woutenindienst = 0


ESX.RegisterServerCallback('nv-juwelierov:hoeveelaanwezig', function(source, cb)
    local xPlayers = ESX.GetPlayers()
    for h=1, #xPlayers, 1 do 
        local xPlayer = ESX.GetPlayerFromId(xPlayers[h])
        if xPlayer.job.name == 'police' then 
            woutenindienst = woutenindienst + 1
        end
    end
    cb(woutenindienst)
    woutenindienst = 0 
end)

Citizen.CreateThread(function()
    while true do 
        Wait(1000)
        for k,v in pairs(NV.Starten) do 
            if v.wachten > 0 then 
                v.wachten = v.wachten - 1
            else
                v.wachten = 0
                v.gestart = false
                TriggerClientEvent("nv-juwelierov:client:Sync", -1 , NV.Starten)
            end
        end
    end
end)


ESX.RegisterServerCallback("nv-juwelierov:aantal", function(source, callback)
    local src = source
    local randy = ESX.GetPlayerFromId(src)
    local juwelen = randy.getInventoryItem('juwel').count
    local max = math.random(1, 9)
    local NV = 0
    local prijs = NV.Prijs
    if juwelen >= max then 
        NV = max 
    else
        NV = juwelen
    end
    if NV > 0 then
        if SecretKey == key then
            TriggerEvent("mn-keyAntiCheat:server:RefreshKey", GetCurrentResourceName(), function(key)
                SecretKey = key
                randy.removeInventoryItem('juwel', NV)
                TriggerClientEvent("notify:sendnotify", src, {
                    ['type'] = "success",
                    ['message'] = "Je hebt " .. NV .." juwelen verkocht voor ".. NV.Prijs .." per stuk."
                })
                randy.addAccountMoney("black_money", NV * NV.Prijs)
                callback(true) 
                TriggerClientEvent("mn-keyAntiCheat:client:RefreshKey", -1, key, GetCurrentResourceName())
            end)
        else
            TriggerEvent("mn-keyAnticheat:server:banPlayer", src, GetCurrentResourceName())
        end
    end
end)

RegisterServerEvent("nv-juwelierov:server:reward")
AddEventHandler("nv-juwelierov:server:reward", function(key)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    local juwelen = math.random(NV.JuweelMin, NV.JuweelMax)

    if SecretKey == key then
        TriggerEvent("mn-keyAntiCheat:server:RefreshKey", GetCurrentResourceName(), function(key)
            SecretKey = key
            xPlayer.addInventoryItem("juwel", juwelen)
            TriggerClientEvent("notify:sendnotify", src, {
                ['type'] = "success",
                ['message'] = "U hebt " .. juwelen .." juwelen uit de vitrine gepakt."
            })
            TriggerClientEvent("mn-keyAntiCheat:client:RefreshKey", -1, key, GetCurrentResourceName())
        end)
    else
        TriggerEvent("mn-keyAnticheat:server:banPlayer", src, GetCurrentResourceName())
    end
end)

RegisterServerEvent("nv-juwelierov:server:Sync")
AddEventHandler("nv-juwelierov:server:Sync", function(table, coords)
    NV.Starten = table
    TriggerClientEvent("nv-juwelierov:client:Sync", -1, NV.Starten)
end)

RegisterServerEvent('nv-juwelierov:server:melding')
AddEventHandler('nv-juwelierov:server:melding', function(coords)
    Politiemelding(coords)
end)

Politiemelding = function(crds)
    local player = ESX.GetPlayers()

    for i=1, #player, 1 do 
        local job = ESX.GetPlayerFromId(player[i]).job.name
        if job == NV.Politiejob then
            TriggerClientEvent("nv-juwelierov:client:PolitieMelding", player[i], crds)
        end
    end 
end