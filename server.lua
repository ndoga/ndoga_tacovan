ESX = nil
ESX = exports["es_extended"]:getSharedObject()

function debugPrintServer(...)
    if Config and Config.Debug then
        print(...)
    end
end


RegisterNetEvent('vehicle:giveItem', function(item, label)
    local src = source
    debugPrintServer("[SERVER] vehicle:giveItem triggerato per item: " .. item .. " (" .. label .. ") da source: " .. src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.addInventoryItem(item, 1)
        TriggerClientEvent('dream_notifiche:client:Alert', src, "Milano Full RP", "Hai ricevuto: " .. label, 3000, "info")
    else
        debugPrintServer("[SERVER] Impossibile trovare il giocatore con id: " .. src)
    end
end)
