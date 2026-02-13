# funk-system

FiveM Funk- und Leitstellensystem mit:

- Funkkanal Join/Leave
- globaler Job-Whitelist
- kanalbezogener Funkberechtigung
- F10-Menü für Notruf + Leitstelle
- Bürger-Notrufen (Polizei oder Feuerwehr/Rettungsdienst)
- getrennter Einsatzsicht:
  - **Polizei sieht nur Polizei-Einsätze**
  - **Feuerwehr + Rettungsdienst teilen sich eine Leitstelle**
- Fahrzeug-Besetzung und Alarmierung durch Leitstelle

## Installation

1. Ordner in `resources/[local]/funk-system` legen.
2. In `server.cfg`:

```cfg
ensure funk-system
```

## Konfiguration

### 1) Funk-Whitelist

`config.lua`:

```lua
Config.JobWhitelist = { 'police', 'ambulance', 'fire' }
```

- leer/nil = alle Jobs dürfen Funk nutzen
- befüllt = nur gelistete Jobs dürfen Funk nutzen

### 2) Leitstellen-Dienste

```lua
Config.DispatchServices = {
  police = {
    label = 'Polizei Leitstelle',
    jobs = { 'police' }
  },
  fire_ems = {
    label = 'Feuerwehr / Rettungsdienst Leitstelle',
    jobs = { 'ambulance', 'fire' }
  }
}
```

### 3) Alarmierbare Fahrzeuge (vom Server-Team gepflegt)

```lua
Config.DispatchUnits = {
  { id = 'F-11', label = 'HLF 20', service = 'fire_ems', allowedJobs = { 'fire' } },
  { id = 'R-21', label = 'RTW 1', service = 'fire_ems', allowedJobs = { 'ambulance' } },
  { id = 'P-31', label = 'Streifenwagen 1', service = 'police', allowedJobs = { 'police' } }
}
```

## Nutzung im Spiel

## F10-Menü

- `F10` drücken
- Auswahl:
  - `1` = Notruf senden (Bürger)
  - `2` = Leitstelle öffnen (für Polizei / Feuerwehr / Rettungsdienst)

### Bürger (Notruf)

Im F10-Menü:

1. `1` wählen
2. Ziel wählen:
   - `1` Polizei
   - `2` Feuerwehr/Rettungsdienst
3. Notruftext eingeben

Alternativ per Command:

- `/notruf police <text>`
- `/notruf fire_ems <text>`

### Leitstelle (Polizei, Feuerwehr, Rettungsdienst)

Im F10-Menü:

1. `2` wählen
2. Optionen:
   - `1` Einsätze/Fahrzeuge anzeigen
   - `2` Fahrzeug besetzen
   - `3` Fahrzeug freigeben
   - `4` Fahrzeug auf Einsatz alarmieren

Zusatz-Command:

- `/leitstelle`

## Funk-Befehle

- `/funk join <kanal>`
- `/funk leave`
- `/funk status`
- `/funkstatus`

## Test-Plan (dein gewünschter Ablauf)

1. Server starten und `ensure funk-system` ausführen.
2. Mit Bürger-Job einloggen:
   - `F10 -> 1` und Notruf an Polizei/Feuerwehr senden.
3. Mit `police` einloggen:
   - `F10 -> 2 -> 1`:
     - Polizei-Einsätze sichtbar
     - Feuerwehr/RD-Einsätze **nicht** sichtbar
4. Mit `fire` oder `ambulance` einloggen:
   - `F10 -> 2 -> 1`:
     - gemeinsame Einsätze von Feuerwehr/RD sichtbar
     - Polizei-Einsätze **nicht** sichtbar
5. Leitstellen-Fahrzeuge testen:
   - `F10 -> 2 -> 2` Fahrzeug-ID eingeben (besetzen)
   - `F10 -> 2 -> 4` Fahrzeug-ID + Einsatz-ID alarmieren
   - `F10 -> 2 -> 3` Fahrzeug freigeben

## Hinweise

- Voice läuft mit `pma-voice`, sonst optionaler Fallback.
- Job-Erkennung unterstützt ESX und QBCore.
