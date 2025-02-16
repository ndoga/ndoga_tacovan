ESX = nil
ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('vehicle:giveItem', function(item, label)
    local src = source
    print("[SERVER] vehicle:giveItem triggerato per item: " .. item .. " (" .. label .. ") da source: " .. src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.addInventoryItem(item, 1)
        TriggerClientEvent('dream_notifiche:client:Alert', src, "Milano Full RP", "Hai ricevuto: " .. label, 3000, "info")
    else
        print("[SERVER] Impossibile trovare il giocatore con id: " .. src)
    end
end)
