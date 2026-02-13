Config = {}

-- ============================
-- INSTALLATION / STANDALONE
-- ============================
-- true  = ESX/QBCore Job wird bevorzugt genutzt
-- false = immer nur manueller Dienst via /setdienst
Config.UseFrameworkJobs = true

-- Wenn kein Framework-Job gefunden wird:
-- true  = manueller Dienst (/setdienst) als Fallback
-- false = Spieler bleibt ohne Dienst
Config.AllowManualServiceFallback = true

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

Config.DispatchUnits = {
  { id = 'F-11', label = 'HLF 20', service = 'fire_ems', allowedJobs = { 'fire' } },
  { id = 'R-21', label = 'RTW 1', service = 'fire_ems', allowedJobs = { 'ambulance' } },
  { id = 'P-31', label = 'Streifenwagen 1', service = 'police', allowedJobs = { 'police' } }
}

Config.PublicCallTargets = {
  { key = 'police', label = 'Polizei' },
  { key = 'fire_ems', label = 'Feuerwehr / Rettungsdienst' }
}
