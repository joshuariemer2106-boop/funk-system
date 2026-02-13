# funk-system
# funk-system (FiveM)

Funk- und Leitstellensystem für FiveM mit:

- Funkkanälen (`/funk join`, `/funk leave`, `/funk status`)
- Bürger-Notruf (Polizei oder Feuerwehr/Rettungsdienst)
- Leitstelle (Einsätze sehen, Fahrzeuge besetzen/freigeben/alarmieren)
- F10-Menü für schnelle Bedienung

---

## 1) Installation (genau so)

### 1.1 Ordner platzieren
Lege den kompletten Ordner `funk-system` in deinen Resources-Pfad:

- `server-data/resources/funk-system`
- oder `server-data/resources/[local]/funk-system`

Im Ordner müssen diese Dateien vorhanden sein:

- `fxmanifest.lua`
- `config.lua`
- `client/main.lua`
- `server/main.lua`

### 1.2 `server.cfg` anpassen
Füge in deiner `server.cfg` ein:

```cfg
ensure funk-system
```

Empfehlung: `ensure funk-system` nach Voice/Framework-Resources laden (z. B. `pma-voice`, ESX, QBCore).

### 1.3 Server neu laden

```cfg
refresh
ensure funk-system
```

---

## 2) Wichtige Konfiguration (`config.lua`)

Datei: `resources/.../funk-system/config.lua`

### 2.1 Framework/Fallback

```lua
Config.UseFrameworkJobs = true
Config.AllowManualServiceFallback = true
```

- `UseFrameworkJobs = true`: nutzt ESX/QBCore Jobs, wenn verfügbar.
- `AllowManualServiceFallback = true`: erlaubt `/setdienst ...`, wenn kein Framework-Job erkannt wird.

### 2.2 Funk-Whitelist

```lua
Config.JobWhitelist = { 'police', 'ambulance', 'fire' }
```

> Die Jobnamen müssen exakt zu deinem Server passen.

### 2.3 Leitstellen-Dienste

```lua
Config.DispatchServices = {
  police = { jobs = { 'police' } },
  fire_ems = { jobs = { 'ambulance', 'fire' } }
}
```

- `police` sieht nur Polizei-Einsätze.
- `fire_ems` ist gemeinsame Leitstelle für Feuerwehr + Rettungsdienst.

### 2.4 Alarmierbare Fahrzeuge

```lua
Config.DispatchUnits = {
  { id = 'F-11', label = 'HLF 20', service = 'fire_ems', allowedJobs = { 'fire' } },
  { id = 'R-21', label = 'RTW 1', service = 'fire_ems', allowedJobs = { 'ambulance' } },
  { id = 'P-31', label = 'Streifenwagen 1', service = 'police', allowedJobs = { 'police' } }
}
```

Diese Einheiten pflegt euer Server-Team.

---

## 3) Nutzung im Spiel

### 3.1 Bürger (Notruf)

- `F10` drücken
- `1` wählen
- Ziel wählen:
  - `1` Polizei
  - `2` Feuerwehr/Rettungsdienst
- Notruftext eingeben

Alternativ per Befehl:

- `/notruf police <text>`
- `/notruf fire_ems <text>`

### 3.2 Einsatzkräfte (Leitstelle)

Leitstelle öffnen:

- `F10` drücken und `2` wählen
- oder `/leitstelle`

Leitstellen-Aktionen:

- `1` Einsätze/Fahrzeuge anzeigen
- `2` Fahrzeug besetzen
- `3` Fahrzeug freigeben
- `4` Fahrzeug auf Einsatz alarmieren

### 3.3 Funkbefehle

- `/funk join <kanal>`
- `/funk leave`
- `/funk status`
- `/funkstatus`

---

## 4) Ohne ESX/QBCore testen

Wenn Jobs nicht greifen, nutze:

- `/setdienst police`
- `/setdienst fire_ems`
- `/setdienst off`

Damit kannst du das System sofort testen.

---

## 5) Kurz-Testplan

1. `ensure funk-system`
2. Spieler A (Bürger): `F10 -> 1` Notruf an Polizei
3. Spieler B (Polizei): `F10 -> 2 -> 1` → Einsatz sichtbar
4. Spieler C (Feuerwehr/RD): `F10 -> 2 -> 1` → Polizei-Einsatz **nicht** sichtbar
5. Feuerwehr/RD-Notruf senden und Sichtbarkeit gegenprüfen
6. Leitstelle: Fahrzeug besetzen (`2`) und alarmieren (`4`)

---

## 6) Fehlerbehebung

### F10 reagiert nicht
- Prüfe `ensure funk-system`.
- Prüfe Server-Konsole auf Lua-Fehler.  

### Keine Einsätze sichtbar
- Jobnamen in `Config.DispatchServices` prüfen.
- Ohne Framework: `/setdienst police` oder `/setdienst fire_ems` setzen.

### Funkkanal nicht betretbar
- `Config.JobWhitelist` und `Config.RestrictedChannels` prüfen.
- Jobname muss exakt übereinstimmen.

---

## 7) Lokales Packaging (ohne Binärdatei im Repo)

Wenn dein PR-System Binärdateien blockiert, baue die ZIP lokal:

```bash
zip -r funk-system.zip . -x '.git/*' 'funk-system.zip'
```

Optional:d

```bash
sha256sum funk-system.zip
```

Zusatzinfos: `PACKAGE.md`
