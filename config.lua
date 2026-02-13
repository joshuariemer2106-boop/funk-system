Config = {}

-- ============================
-- FUNK / RADIO
-- ============================
Config.MinChannel = 1
Config.MaxChannel = 500

-- Globale Job-Whitelist (leer/nil = alle Jobs)
Config.JobWhitelist = {
  'police',
  'ambulance',
  'fire'
}

-- Kanal-spezifische Berechtigungen
Config.RestrictedChannels = {
  [1] = { jobs = { 'police' } },
  [2] = { jobs = { 'ambulance', 'fire' } }
}

Config.AllowFallbackWithoutVoiceExport = true

-- ============================
-- LEITSTELLE / EINSATZ-SYSTEM
-- ============================

-- Welche Jobs zu welchem Dienst gehören
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

-- Server-Team kann hier die alarmierbaren Fahrzeuge pflegen
-- service = welche Leitstelle das Fahrzeug alarmieren darf
-- allowedJobs = welche Jobs das Fahrzeug "besetzen" dürfen
Config.DispatchUnits = {
  { id = 'F-11', label = 'HLF 20', service = 'fire_ems', allowedJobs = { 'fire' } },
  { id = 'R-21', label = 'RTW 1', service = 'fire_ems', allowedJobs = { 'ambulance' } },
  { id = 'P-31', label = 'Streifenwagen 1', service = 'police', allowedJobs = { 'police' } }
}

-- Notruf-Kategorien für Bürger
Config.PublicCallTargets = {
  { key = 'police', label = 'Polizei' },
  { key = 'fire_ems', label = 'Feuerwehr / Rettungsdienst' }
}
