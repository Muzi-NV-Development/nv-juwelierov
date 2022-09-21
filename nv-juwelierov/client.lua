ESX = nil

local inrun = false
local currentjob = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData() == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
    Citizen.Wait(10)

    ESX.TriggerServerCallback("mn-keyAnticheat:server:requestKey", function(key)
        SecretKey = key
    end, GetCurrentResourceName())
end)

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local tikkie = 500

        for k,v in pairs(NV.Starten) do
            local x,y,z = table.unpack(v.coords)
            local dist = GetDistanceBetweenCoords(coords, x,y,z, true)
            if dist <= 10 then
                tikkie = 1
                if dist <= 5 then
                    DrawMarker(20, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.3, 0.2, 0, 118, 196, 100, false, true, 2, true, nil, nil, false)
                    if not v.gestart then
                        if dist <= 0.5 then
                            DrawScriptText(vector3(x,y,z), "[~b~E~w~] Juwelier overvallen")
                            if IsControlJustReleased(0, 38) then
                                if IsPedArmed(GetPlayerPed(-1), 4) then
                                    v.gestart = true
                                    v.wachten = NV.Cooldown
                                    TriggerServerEvent("nv-juwelierov:server:Sync", NV.Starten, coords)
                                    TriggerServerEvent('nv-juwelierov:server:melding', coords)
                                    bezig = true
                                    starten()
                                    exports["nv-melding"]:TriggerNotification({
                                        ['type'] = "error",
                                        ['message'] = "Overval gestart"
                                    }) 
                                else
                                    exports["nv-melding"]:TriggerNotification({
                                        ['type'] = "error",
                                        ['message'] = "Niemand is bang voor je, zonder wapen."
                                    }) 
                                end
                            end
                        end
                    else
                        DrawScriptText(vector3(x,y,z), "Overvallen niet mogelijk...")
                    end
                end
            end
        end
        Wait(tikkie)
    end
end)
                        


RegisterNetEvent("mn-keyAntiCheat:client:RefreshKey")
AddEventHandler("mn-keyAntiCheat:client:RefreshKey", function(key, resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SecretKey = key
end)

starten = function()
    Citizen.CreateThread(function()
        while true do
            local ped = GetPlayerPed(-1)
            local coords = GetEntityCoords(ped)
            local tiktak = 500

            for k,v in pairs(NV.Glazenmeuk) do
                local x,y,z = table.unpack(v.coords)
                local dist = GetDistanceBetweenCoords(coords, x,y,z, true)
                if dist < 5 then
                    tiktak = 1
                    if dist < 0.5 then
                        if bezig then
                            if not v.getimmerd then
                                DrawScriptText(vector3(x,y,z), "[~b~E~w~] Sla in")
                                if IsControlJustReleased(0, 38) then
                                    ESX.TriggerServerCallback('nv-juwelierov:hoeveelaanwezig', function(agenten)
                                        if agenten >= NV.AgentNodig then
                                            if IsPedArmed(GetPlayerPed(-1), 4) then
                                                v.getimmerd = true
                                                inslaan()
                                            else
                                                exports["nv-melding"]:TriggerNotification({
                                                    ['type'] = "error",
                                                    ['message'] = "Niemand is bang voor je, zonder wapen."
                                                }) 
                                            end
                                        else
                                            exports["nv-melding"]:TriggerNotification({
                                                ['type'] = "error",
                                                ['message'] = "Er zijn niet genoeg agenten (" .. agenten .. "/" .. NV.AgentNodig .. ")"
                                            }) 
                                        end
                                    end)
                                end
                            else
                                DrawScriptText(vector3(x,y,z), "Vitrinekast is al kapot..")
                            end
                        end
                    end
                end
            end
            Wait(tiktak)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local tiktok = 500

        for k,v in pairs(NV.Verkooppunt) do
            local x,y,z = table.unpack(v.coords)
            local dist = GetDistanceBetweenCoords(coords, x,y,z, true)

            if dist <= 5 then
                tiktok = 1
                if dist < 2 then
                    if not inrun then
                        DrawScriptText(vector3(x,y,z), "[~b~E~w~] Verkopen")
                        if IsControlJustReleased(0, 38) then
                            startrun()
                        end
                    else
                        DrawScriptText(vector3(x,y,z), "Je hebt al een run lopen...")
                    end
                end
            end
        end
        Wait(tiktok)
    end
end)

RegisterNetEvent("nv-juwelierov:client:Sync")
AddEventHandler("nv-juwelierov:client:Sync", function(table)
    NV.Starten = table
end)

RegisterNetEvent("nv-juwelierov:client:PolitieMelding")
AddEventHandler("nv-juwelierov:client:PolitieMelding", function(position)
    exports['nv-notify']:grootnotify('[112 Meldkamer]', 'Juwelier overval gemeld \n \n \n \n Locatie aangegeven op de map!', 'fas fa-bullhorn', '6000', '#0076c4', true)
    blipRobbery = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(blipRobbery , 161)
    SetBlipScale(blipRobbery , 2.0)
    SetBlipColour(blipRobbery, 1)
    PulseBlip(blipRobbery)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Juwelier overval')
    EndTextCommandSetBlipName(blipRobbery)

    Wait(60000)
    RemoveBlip(blipRobbery)
end)


function loadAnimDict( dict )  
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

startrun = function()
    gestart = true
    plak = CreateObject(`p_amb_clipboard_01`, true, true, true)
    AttachEntityToEntity(plak, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 36029), 0.16, 0.08, 0.1, -130.0, -50.0, 0.0, true, true, false, true, 1, true)
	Progressbar("startrun", 'Locaties aan het ophalen', 10000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
        animDict = "missfam4",
        anim = "base",
		flags = 49,
	}, {}, {}, function()
        DeleteObject(plak)
        exports["nv-melding"]:TriggerNotification({
            ['type'] = "error",
            ['message'] = "GPS Ingesteld"
        })
        currentjob = math.random(1, #NV.Verkooppunten)
        Maakblip()
        inrun = true
	end)
end

Citizen.CreateThread(function()
    while true do
        Wait(5)
        if inrun then
            if currentjob ~= nil then
                local dist = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), NV.Verkooppunten[currentjob].x, NV.Verkooppunten[currentjob].y, NV.Verkooppunten[currentjob].z, true)
                if dist < 3 then
                    slaap = false
                    DrawMarker(20,NV.Verkooppunten[currentjob].x, NV.Verkooppunten[currentjob].y, NV.Verkooppunten[currentjob].z - 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.3, 0.2, 46, 122, 221, 100, false, true, 2, true, nil, nil, false)
                    DrawScriptText(vector3(NV.Verkooppunten[currentjob].x, NV.Verkooppunten[currentjob].y, NV.Verkooppunten[currentjob].z), '~b~E ~w~· Verkopen')
                    if IsControlJustReleased(0, 38) then
                        RequestAnimDict("timetable@jimmy@doorknock@")
                        PlayAnimation(PlayerPedId(), "timetable@jimmy@doorknock@", "knockdoor_idle")
                        Wait(1500)
                        ESX.TriggerServerCallback('nv-juwelierov:aantal', function(NV)
                            if NV then
                                currentjob = math.random(1, #NV.Verkooppunten)
                                verwijderblip()
                            else
                                exports["nv-melding"]:TriggerNotification({
                                    ['type'] = "error",
                                    ['message'] = "Je hebt geen telefoons meer"
                                })
                                gestart = false
                                inrun = false
                                RemoveBlip(currentblip)
                            end
                        end)
                    end
                end
                if slaap then
                    Wait(1000)
                end
            end
        end
    end
end)

verwijderblip = function()
    RemoveBlip(currentblip)
    Maakblip()
end

Maakblip = function()
    currentblip = AddBlipForCoord(NV.Verkooppunten[currentjob].x, NV.Verkooppunten[currentjob].y, NV.Verkooppunten[currentjob].z)
    SetBlipSprite (currentblip, 280)
    SetBlipDisplay(currentblip, 4)
    SetBlipScale  (currentblip, 0.6)
    SetBlipAsShortRange(currentblip, true)
    SetBlipColour (currentblip, 3)
    SetBlipRoute(currentblip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Verkoop Punt')
    EndTextCommandSetBlipName(currentblip)
end


inslaan = function()
    Citizen.CreateThread(function()
        for k,v in pairs(NV.Glazenmeuk) do
            local x,y,z = table.unpack(v.coords)
            PlaySoundFromCoord(-1, "Glass_Smash", v.x, v.y, v.z, "", 0, 0, 0)
            if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
            RequestNamedPtfxAsset("scr_jewelheist")
            end
            while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
            Citizen.Wait(0)
            end
            SetPtfxAssetNextCall("scr_jewelheist")
            StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", v.coords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            loadAnimDict( "missheist_jewel" ) 
            TaskPlayAnim(GetPlayerPed(-1), "missheist_jewel", "smash_case", 8.0, 1.0, -1, 2, 0, 0, 0, 0 ) 
            Progressbar("inslaan", "Vitrine kapotslaan..", 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "missheist_jewel",
                anim = "smash_case",
                flags = 16,
            }, {}, {}, function() 
                ClearPedTasksImmediately(GetPlayerPed(-1))
                TriggerServerEvent("nv-juwelierov:server:reward", SecretKey)
            end, function() 
                ClearPedTasksImmediately(GetPlayerPed(-1))
            end)
        end
    end)
end

PlayAnimation = function(ped, dict, anim, settings)
	if dict then
        Citizen.CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else 
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
      
            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(ped, anim, 0, true)
	end
end

Citizen.CreateThread(function()
    juwelier = AddBlipForCoord(-628.9921, -235.5566, 38.0570)
    SetBlipSprite(juwelier, 186)
    SetBlipScale(juwelier, 1.0)
    SetBlipColour(juwelier, 38)
    SetBlipAsShortRange(juwelier, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Juwelier Overval')
    EndTextCommandSetBlipName(juwelier)
end)


function DrawScriptText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords["x"], coords["y"], coords["z"])

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = string.len(text) / 370

    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 65)
end


Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    exports['progressbar']:Progress({
        name = name:lower(),
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        controlDisables = disableControls,
        animation = animation,
        prop = prop,
        propTwo = propTwo,
    }, function(cancelled)
        if not cancelled then
            if onFinish ~= nil then
                onFinish()
            end
        else
            if onCancel ~= nil then
                onCancel()
            end
        end
    end)
end
