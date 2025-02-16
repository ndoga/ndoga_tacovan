-- Inizializzazione di ESX Legacy
ESX = exports["es_extended"]:getSharedObject()

-- Definisci la variabile globale 'lib' per accedere agli export di ox_lib
lib = exports.ox_lib

function debugPrint(...)
    if Config and Config.Debug then
        print(...)
    end
end

function ProgressBarPromise(options)
    local p = promise.new()
    exports.ox_lib:progressBar(options, function(status)
        p:resolve(status)
    end)
    return Citizen.Await(p)
end

-- Funzione per caricare un dizionario di animazioni
function EnsureAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
end

-- Verifica in console gli export disponibili
Citizen.CreateThread(function()
    Wait(1000)
    debugPrint("registerContext:", lib.registerContext)
    debugPrint("showContext:", lib.showContext)
end)

---------------------------------------------------------------
-- Fallback per Config.Menus, se non definito (per sicurezza)
---------------------------------------------------------------
if not Config or not Config.Menus then
    debugPrint("Config.Menus non è definito! Uso i valori di default.")
    Config = {
        Menus = {
            Beverage = {
                title = "Bibite/Bevande",
                items = {
                    { label = "Coca Cola", item = "cola", progress = 3000, animType = "beverage" },
                    { label = "Acqua",      item = "water",    progress = 3000, animType = "beverage" },
                }
            },
            Food = {
                title = "Cibo",
                items = {
                    { label = "Hamburger", item = "burger", progress = 10000, animType = "food" },
                    { label = "Pizza",     item = "pizza",     progress = 10000, animType = "food" },
                }
            }
        }
    }
end

---------------------------------------------------------------
-- Funzione per ottenere il job del giocatore
---------------------------------------------------------------
function GetPlayerJob()
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.name
    end
    return nil
end

---------------------------------------------------------------
-- Notifiche (utilizzando dream_notifiche)
---------------------------------------------------------------
RegisterNetEvent('dream_notifiche:client:Alert', function(title, message, duration, type)
    exports['dream_notifiche']:Alert(title, message, duration, type)
end)

---------------------------------------------------------------
-- Gestione del target sul veicolo (usando ox_target)
---------------------------------------------------------------

-- Assicurati che Config.Vehicles sia definito in config.lua
-- Esempio (in config.lua):
-- Config.Vehicles = {
--     ["furgonekeg"] = {
--         requiredJob = "keg",
--         targetOffset = vector3(0.0, 0.0, 1.5),
--         targetZoneSize = vector3(1.0, 1.0, 2.0)
--     }
-- }

local vehicleConfig = {}
for modelName, data in pairs(Config.Vehicles or {}) do
    vehicleConfig[GetHashKey(modelName)] = data
end

local zoneAdded = false
local zoneName = "vehicle_target_zone"
local speedThreshold = 0.5 -- Il veicolo è considerato fermo se la velocità < 0.5 m/s
local lastZoneCoords = nil
local lastZoneRotation = nil

local function AddTargetZone(veh, configData)
    local coords = GetOffsetFromEntityInWorldCoords(veh, configData.targetOffset.x, configData.targetOffset.y, configData.targetOffset.z)
    local rotation = GetEntityHeading(veh)
    debugPrint("[TARGET] Aggiungo target in posizione:", coords.x, coords.y, coords.z, "rotazione:", rotation)
    
    exports.ox_target:addBoxZone({
        name = zoneName,
        coords = coords,
        size = configData.targetZoneSize,
        rotation = rotation,
        debug = Config.Debug,
        options = {
            {
                name = zoneName,
                icon = 'fa-solid fa-utensils',
                label = 'Apri Menu',
                onSelect = function(data)
                    if configData.requiredJob then
                        if GetPlayerJob() == configData.requiredJob then
                            TriggerEvent('vehicle:openMenu')
                        else
                            exports['dream_notifiche']:Alert("Milano Full RP", "Non hai il permesso!", 3000, "info")
                        end
                    else
                        TriggerEvent('vehicle:openMenu')
                    end
                end,
            }
        }
    })
    zoneAdded = true
    lastZoneCoords = coords
    lastZoneRotation = rotation
end

local function RemoveTargetZone()
    if zoneAdded then
        debugPrint("[TARGET] Rimuovo target")
        exports.ox_target:removeZone(zoneName)
        zoneAdded = false
        lastZoneCoords = nil
        lastZoneRotation = nil
    end
end

local function rotationChanged(oldRot, newRot)
    return math.abs(newRot - oldRot) > 5
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local targetVeh = nil
        local configData = nil

        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            if veh and veh ~= 0 and vehicleConfig[GetEntityModel(veh)] then
                targetVeh = veh
                configData = vehicleConfig[GetEntityModel(veh)]
            end
        else
            local playerCoords = GetEntityCoords(playerPed)
            local veh = GetClosestVehicle(playerCoords, 10.0, 0, 70)
            if veh and veh ~= 0 and DoesEntityExist(veh) and vehicleConfig[GetEntityModel(veh)] then
                targetVeh = veh
                configData = vehicleConfig[GetEntityModel(veh)]
            end
        end

        if targetVeh and DoesEntityExist(targetVeh) then
            local speed = GetEntitySpeed(targetVeh)
            if speed < speedThreshold then
                local newCoords = GetOffsetFromEntityInWorldCoords(targetVeh, configData.targetOffset.x, configData.targetOffset.y, configData.targetOffset.z)
                local newRotation = GetEntityHeading(targetVeh)
                if not zoneAdded then
                    debugPrint("[TARGET] Veicolo fermo: aggiungo target")
                    AddTargetZone(targetVeh, configData)
                else
                    if Vdist(newCoords.x, newCoords.y, newCoords.z, lastZoneCoords.x, lastZoneCoords.y, lastZoneCoords.z) > 0.1 or rotationChanged(lastZoneRotation, newRotation) then
                        debugPrint("[TARGET] Aggiorno target")
                        RemoveTargetZone()
                        AddTargetZone(targetVeh, configData)
                    end
                end
            else
                if zoneAdded then
                    debugPrint("[TARGET] Veicolo in movimento: rimuovo target")
                    RemoveTargetZone()
                end
            end
        else
            if zoneAdded then
                debugPrint("[TARGET] Nessun veicolo configurato trovato: rimuovo target")
                RemoveTargetZone()
            end
        end
    end
end)

---------------------------------------------------------------
-- MENU DEFAULT DI ESX (in basso a destra)
---------------------------------------------------------------

-- Funzione per gestire la progress bar, l'animazione e la consegna dell'item
function ProcessItemESX(item, label, duration, animType)
    local animDict, animClip
    if animType == "beverage" then
        -- Proviamo con l'animazione di inchino
        animDict = "amb@world_human_bum_wash@male@high@base"
        animClip = "base"
        debugPrint("Usando animazione BEVERAGE: " .. animDict .. ", " .. animClip)
        -- Se non funziona, puoi provare decommentando la riga seguente:
        -- animDict = "mp_player_intdrink"; animClip = "intro_bottle"
    elseif animType == "food" then
        animDict = "amb@prop_human_bbq@male@idle_a"
        animClip = "idle_a"
        debugPrint("Usando animazione FOOD: " .. animDict .. ", " .. animClip)
    else
        debugPrint("Animazione non definita per: " .. label)
        return
    end

    debugPrint("Carico dizionario animazione: " .. animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end
    debugPrint("Dizionario caricato: " .. animDict)

    ESX.UI.Menu.CloseAll()

    if exports.ox_lib:progressBar({
        duration = duration,
        label = "Preparazione " .. label,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = animDict, clip = animClip, flag = 49 },
    }) then 
        debugPrint("ProgressBar Terminata: Triggero l'evento server per dare l'item: " .. item)
        TriggerServerEvent("vehicle:giveItem", item, label)
     else 
        debugPrint("ProgressBar Annulata")
        exports['dream_notifiche']:Alert("Milano Full RP", "Operazione annullata", 3000, "info")
    end
end

-- Menu principale ESX (in basso a destra)
function OpenMainMenuESX()
    local elements = {
        { label = "Bibite/Bevande", value = "beverage" },
        { label = "Cibo", value = "food" }
    }
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_main_menu', {
        title = "Interazione Veicolo",
        align = 'bottom-right',
        elements = elements
    }, function(data, menu)
        if data.current.value == "beverage" then
            OpenSubMenuESX("Bibite")
        elseif data.current.value == "food" then
            OpenSubMenuESX("Cibo")
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Submenu ESX per categoria
function OpenSubMenuESX(category)
    local elements = {}
    if category == "Bibite" then
        table.insert(elements, { label = "Coca Cola", value = "cocacola" })
        table.insert(elements, { label = "Acqua", value = "water" })
    elseif category == "Cibo" then
        table.insert(elements, { label = "Hamburger", value = "hamburger" })
        table.insert(elements, { label = "Pizza", value = "pizza" })
    else
        debugPrint("Categoria non riconosciuta: " .. tostring(category))
        return
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_sub_menu', {
        title = category,
        align = 'bottom-right',
        elements = elements
    }, function(data, menu)
        local item = data.current.value
        local label = data.current.label
        local duration, animType
        if category == "Bibite" then
            duration = 3000
            animType = "beverage"
        else
            duration = 10000
            animType = "food"
        end
        ProcessItemESX(item, label, duration, animType)
        menu.close()
    end, function(data, menu)
        menu.close()
        OpenMainMenuESX()
    end)
end

---------------------------------------------------------------
-- Evento per aprire il menu (triggerato dal target)
---------------------------------------------------------------
RegisterNetEvent('vehicle:openMenu', function()
    OpenMainMenuESX()
end)
