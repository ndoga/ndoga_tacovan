# Vehicle Target

Version: 1.0.0
Author: ndo.ga
Discord: https://discord.gg/HQQYQGbyn3

Vehicle Target è uno script per FiveM che permette di creare un target interattivo sui veicoli e di aprire un menu per l'interazione, consentendo ai giocatori di ottenere oggetti (cibo e bevande) tramite una progress bar con animazioni.
Lo script sfrutta ESX Legacy, ox_target, ox_lib e dream_notifiche per offrire una soluzione modulare e facilmente personalizzabile.

---------------------------------------------------------------
## CARATTERISTICHE

- Target Interattivo sui Veicoli:
  Quando un veicolo configurato (ad esempio, "furgonekeg") è fermo, viene creato un target interattivo.
  Se il veicolo si muove o non viene rilevato, il target viene rimosso automaticamente.

- Menu di Interazione:
  Cliccando sul target, viene aperto un menu ESX (posizionato in basso a destra) che consente di scegliere tra "Bibite/Bevande" e "Cibo".
  Se il target richiede un job specifico, viene controllato il job del giocatore.

- Progress Bar e Animazioni:
  Dopo aver selezionato un'opzione dal menu, viene avviata una progress bar:
    • Bevande: il giocatore esegue un'animazione di inchino.
    • Cibo: il giocatore esegue un'animazione BBQ (griglia).
  Al termine della progress bar, viene triggerato un evento server che aggiunge l’item all’inventario ESX e viene mostrata una notifica tramite dream_notifiche.

- Configurazione Generica:
  Il file config.lua permette di:
    • Abilitare o disabilitare il debug (per visualizzare o meno messaggi di log e il box di debug).
    • Configurare i menu (etichette, item, durata della progress bar, animazioni).
    • Configurare i veicoli target (modello, offset, dimensioni e job richiesto per l'interazione).

---------------------------------------------------------------
## REQUISITI

- es_extended (ESX Legacy)
  https://github.com/esx-framework/es_extended

- ox_target
  https://github.com/overextended/ox_target

- ox_lib
  https://github.com/overextended/ox_lib

- dream_notifiche (o un sistema di notifiche compatibile che espone l'export "Alert")
  https://discord.gg/HQQYQGbyn3

---------------------------------------------------------------
## INSTALLAZIONE

1. Scarica il repository e posiziona la cartella (ad esempio, "ndoga_tacovan") nella cartella "resources" del tuo server FiveM.
2. Aggiungi il resource nel tuo server.cfg:
   ensure ndoga_tacovan
3. Assicurati di avere installato e avviato correttamente le seguenti risorse:
   - es_extended (ESX Legacy)
   - ox_target
   - ox_lib
   - dream_notifiche

---------------------------------------------------------------
## CONFIGURAZIONE

Il file config.lua contiene tutte le impostazioni necessarie.

Esempio di config.lua:

```Config = {}

-- Abilita/disabilita il debug (true per attivare, false per disattivare)
Config.Debug = true

-- Configurazione dei menu
Config.Menus = {
    Beverage = {
        title = "Bibite/Bevande",
        items = {
            { label = "Coca Cola", item = "cola", progress = 3000, animType = "beverage" },
            { label = "Acqua",      item = "water", progress = 3000, animType = "beverage" },
        }
    },
    Food = {
        title = "Cibo",
        items = {
            { label = "Hamburger", item = "burger", progress = 10000, animType = "food" },
            { label = "Pizza",     item = "pizza", progress = 10000, animType = "food" },
        }
    }
}

-- Configurazione dei veicoli target
Config.Vehicles = {
    ["furgonekeg"] = {
        requiredJob = "keg",  -- Imposta il job richiesto; se non necessario, rimuovi questa proprietà
        targetOffset = vector3(0.0, 0.0, 1.5),
        targetZoneSize = vector3(1.0, 1.0, 2.0)
    }
}
```

---------------------------------------------------------------
## USO

1. Target:
   Quando un veicolo configurato (ad esempio, "furgonekeg") è fermo, viene creato un target interattivo.
   Se il veicolo si muove o non viene rilevato, il target viene rimosso automaticamente.

2. Interazione:
   Cliccando sul target, viene aperto un menu ESX (in basso a destra) che permette al giocatore di scegliere tra
   "Bibite/Bevande" e "Cibo". Se il target è configurato per richiedere un job specifico, viene controllato il job del giocatore.

3. Progress Bar e Animazioni:
   Dopo aver selezionato un'opzione dal menu, viene avviata una progress bar:
     - Bevande: il giocatore esegue un'animazione di inchino.
     - Cibo: il giocatore esegue un'animazione BBQ (griglia).
   Al termine della progress bar, viene triggerato un evento server per aggiungere l’item all’inventario ESX e viene mostrata una notifica tramite dream_notifiche.

---------------------------------------------------------------
## CONTRIBUTI

Se desideri contribuire o segnalare problemi, apri una issue o invia una pull request.
Ogni contributo è ben accetto!

---------------------------------------------------------------
## LICENZA

Distribuito con licenza MIT.
Vedi il file LICENSE per ulteriori dettagli.
-----------------------------------------------------------
