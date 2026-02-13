# funk-system (FiveM)

Dieses Resource ist ein Funk- und Leitstellensystem mit:

- Funkkanälen (`/funk join`, `/funk leave`, `/funk status`)
- Bürger-Notruf (Polizei / Feuerwehr-Rettungsdienst)
- Leitstellen-Funktionen (Einsätze sehen, Fahrzeuge besetzen/freigeben/alarmieren)
- F10-Menü für schnelle Nutzung

---

## 1) EXAKTE INSTALLATION (Schritt für Schritt)

### Schritt 1: Resource-Ordner richtig ablegen

Lege den **kompletten Ordner** `funk-system` in deinen FiveM-Resources-Pfad.

Typische Pfade:

- `server-data/resources/funk-system`
- oder `server-data/resources/[local]/funk-system`

Wichtig ist nur: im Ordner müssen diese Dateien liegen:

- `fxmanifest.lua`
- `config.lua`
- `client/main.lua`
- `server/main.lua`

### Schritt 2: In `server.cfg` eintragen

Öffne deine `server.cfg` und füge diese Zeile ein:

```cfg
ensure funk-system
```

Empfehlung: trage `ensure funk-system` **nach** Voice/Framework-Resources ein (z. B. nach `pma-voice`, ESX/QBCore), damit alles sicher geladen ist.

### Schritt 3: Server neu starten

- Komplett neustarten **oder** in der Server-Konsole:

```cfg
refresh
ensure funk-system
```

---

## 2) WAS DU IN `config.lua` ANPASSEN MUSST

Datei: `resources/.../funk-system/config.lua`

### A) Framework / Standalone Verhalten

```lua
Config.UseFrameworkJobs = true
Config.AllowManualServiceFallback = true
```

- `UseFrameworkJobs = true`: ESX/QBCore Jobs werden verwendet, falls vorhanden.
- `AllowManualServiceFallback = true`: wenn kein Job erkannt wird, kannst du manuell Dienst setzen mit `/setdienst ...`.

### B) Funk-Whitelist

```lua
Config.JobWhitelist = { 'police', 'ambulance', 'fire' }
```

Diese Jobnamen müssen zu deinen echten Jobnamen auf dem Server passen.

### C) Leitstellen-Dienste

```lua
Config.DispatchServices = {
  police = { jobs = { 'police' } },
  fire_ems = { jobs = { 'ambulance', 'fire' } }
}
```

- `police` sieht nur Polizei-Einsätze
- `fire_ems` ist die gemeinsame Leitstelle für Feuerwehr + Rettungsdienst

### D) Fahrzeuge, die alarmierbar sind

```lua
Config.DispatchUnits = {
  { id = 'F-11', label = 'HLF 20', service = 'fire_ems', allowedJobs = { 'fire' } },
  { id = 'R-21', label = 'RTW 1', service = 'fire_ems', allowedJobs = { 'ambulance' } },
  { id = 'P-31', label = 'Streifenwagen 1', service = 'police', allowedJobs = { 'police' } }
}
```

Diese Liste pflegst du so, wie euer Serverteam die Einheiten benennt.

---

## 3) NUTZUNG IM SPIEL

## Bürger (ohne Job)

- `F10` drücken
- `1` wählen (Notruf)
- Ziel wählen:
  - `1` Polizei
  - `2` Feuerwehr/Rettungsdienst
- Notruftext eingeben

Alternativ:

- `/notruf police <text>`
- `/notruf fire_ems <text>`

## Einsatzkräfte

### Leitstelle öffnen

- `F10` drücken
- `2` wählen

oder

- `/leitstelle`

### Leitstellen-Aktionen

- `1` Einsätze/Fahrzeuge anzeigen
- `2` Fahrzeug besetzen
- `3` Fahrzeug freigeben
- `4` Fahrzeug auf Einsatz alarmieren

### Funk

- `/funk join <kanal>`
- `/funk leave`
- `/funk status`
- `/funkstatus`

---

## 4) WENN DU KEIN ESX/QBCore VERWENDEST (oder Jobs nicht greifen)

Nutze den manuellen Dienstbefehl:

- `/setdienst police`
- `/setdienst fire_ems`
- `/setdienst off`

Damit kannst du sofort testen, auch ohne Framework-Job-Zuordnung.

---

## 5) SCHNELLER TESTPLAN

1. Resource installiert + `ensure funk-system`
2. Spieler A (Bürger): `F10 -> 1` Notruf an Polizei
3. Spieler B (Polizei): `F10 -> 2 -> 1` und prüft, dass der Einsatz sichtbar ist
4. Spieler C (Feuerwehr/RD): `F10 -> 2 -> 1` und prüft, dass **Polizei-Einsatz nicht sichtbar** ist
5. Feuerwehr/RD-Notruf senden und umgekehrt prüfen
6. In Leitstelle Fahrzeug besetzen (`2`) und auf Einsatz alarmieren (`4`)

---

## 6) TROUBLESHOOTING

### F10 macht nichts

- Prüfe, ob `ensure funk-system` wirklich aktiv ist.
- Prüfe Server-Konsole auf Lua-Fehler.

### Ich sehe keine Einsätze

- Prüfe Jobnamen in `Config.DispatchServices`.
- Falls ohne Framework: `/setdienst police` oder `/setdienst fire_ems` setzen.

### Funkkanal kann nicht betreten werden

- Prüfe `Config.JobWhitelist` und `Config.RestrictedChannels`.
- Jobname muss exakt passen.

## 7) LOCAL PACKAGING (ohne Binärdatei im Repo)

Wenn dein PR-System Binärdateien blockiert, erstelle die ZIP **lokal** statt sie zu committen.

Befehl im Projektordner:

```bash
zip -r funk-system.zip . -x '.git/*' 'funk-system.zip'
```

Optional:

```bash
sha256sum funk-system.zip
```

Siehe auch `PACKAGE.md`.

