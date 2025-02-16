Config = {}

-- Configurazione dei veicoli: per ogni modello (nome in minuscolo) specifichiamo:
-- - requiredJob: il job richiesto per interagire
-- - targetOffset: posizione del target (vector3) rispetto al veicolo
-- - targetZoneSize: dimensione dell'area interattiva
Config.Vehicles = {
    ["furgonekeg"] = {
        requiredJob = "keg",
        targetOffset = vector3(0.0, 0.0, 1.5),
        targetZoneSize = vector3(1.0, 1.0, 2.0)
    },
    -- Aggiungi altri veicoli qui...
}

-- Configurazione dei menu per interazioni:
-- In Config.Menus vengono definiti due menu:
--   * Beverage: per le bibite/bevande (durata 3000 ms, animazione beverage)
--   * Food: per il cibo (durata 10000 ms, animazione food)
Config.Menus = {
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

-- Abilita/disabilita il debug (true per vedere i messaggi e il box di debug, false per disattivare)
Config.Debug = false
