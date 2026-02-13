# funk-system

Plug-and-play FiveM Funk- & Leitstellensystem.

## Quick Installation (nur 1 Ordner)

1. Diesen Ordner nach `resources/funk-system` kopieren.
2. In `server.cfg` **eine Zeile** hinzufügen:

```cfg
ensure funk-system
```

Danach Server starten/restarten – fertig.

## Sofort testen (ohne extra Setup)

Wenn du **kein ESX/QBCore** nutzt oder Jobs noch nicht sauber gesetzt sind:

- `/setdienst police` → Polizei-Dienst
- `/setdienst fire_ems` → Feuerwehr/RD-Dienst
- `/setdienst off` → zurück zu Bürger

Dann:
- `F10` → `1` Notruf senden (Bürger)
- `F10` → `2` Leitstelle öffnen (nur mit Dienst)

## Features

- Funkkanäle mit Whitelist + Kanalregeln
- Bürger-Notruf
- Leitstelle mit Einsätzen/Fahrzeugen
- Fahrzeug besetzen / freigeben / alarmieren
- Getrennte Sicht:
  - Polizei sieht nur Polizei-Einsätze
  - Feuerwehr+RD sehen nur Feuerwehr/RD-Einsätze

## Standard-Befehle

- `/funk join <kanal>`
- `/funk leave`
- `/funk status`
- `/notruf police <text>`
- `/notruf fire_ems <text>`
- `/leitstelle`
- `/setdienst police|fire_ems|off`

## Konfiguration (optional)

Du kannst später in `config.lua` anpassen:
- Funk-Whitelist (`Config.JobWhitelist`)
- Dienste (`Config.DispatchServices`)
- Fahrzeuge (`Config.DispatchUnits`)

Standard läuft aber direkt nach Installation.


## Hinweis zu PRs ohne Binärdateien

Wenn dein PR-System keine Binärdateien unterstützt, wird `funk-system.zip` bewusst **nicht** ins Repository committed.
Erstelle die ZIP stattdessen lokal mit:

```bash
zip -r funk-system.zip . -x '.git/*' 'funk-system.zip'
```

Details stehen in `PACKAGE.md`.
