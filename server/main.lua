local playerChannels = {}
local dispatchCalls = {}
local dispatchUnits = {}
local nextCallId = 1

for _, unit in ipairs(Config.DispatchUnits or {}) do
  dispatchUnits[unit.id] = {
    id = unit.id,
    label = unit.label,
    service = unit.service,
    allowedJobs = unit.allowedJobs,
    occupiedBy = nil,
    occupiedByName = nil,
    lastAlarmCallId = nil
  }
end

local function getPlayerNameSafe(src)
  return GetPlayerName(src) or ('ID %s'):format(src)
end

local function getFrameworkJob(source)
  if GetResourceState('es_extended') == 'started' then
    local ESX = exports['es_extended']:getSharedObject()
    local xPlayer = ESX and ESX.GetPlayerFromId and ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job and xPlayer.job.name then
      return xPlayer.job.name
    end
  end

  if GetResourceState('qb-core') == 'started' then
    local QBCore = exports['qb-core']:GetCoreObject()
    local player = QBCore and QBCore.Functions and QBCore.Functions.GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name then
      return player.PlayerData.job.name
    end
  end

  return nil
end

local function isJobInList(jobName, allowedJobs)
  if not allowedJobs or #allowedJobs == 0 then
    return true
  end

  if not jobName then
    return false
  end

  for _, allowedJob in ipairs(allowedJobs) do
    if allowedJob == jobName then
      return true
    end
  end

  return false
end

local function getPlayerService(job)
  for serviceKey, service in pairs(Config.DispatchServices or {}) do
    if isJobInList(job, service.jobs) and job ~= nil then
      return serviceKey
    end
  end

  return nil
end

local function isAllowedOnChannel(source, channel)
  local job = getFrameworkJob(source)

  if not isJobInList(job, Config.JobWhitelist) then
    return false, 'Dein Job ist nicht in der globalen Funk-Whitelist.'
  end

  local restriction = Config.RestrictedChannels[channel]
  if not restriction then
    return true
  end

  if not isJobInList(job, restriction.jobs) then
    return false, 'Du hast keine Berechtigung für diesen Kanal.'
  end

  return true
end

local function getVisibleDispatchStateForPlayer(src)
  local job = getFrameworkJob(src)
  local service = getPlayerService(job)

  if not service then
    return {}, {}
  end

  local visibleCalls = {}
  for _, call in ipairs(dispatchCalls) do
    if call.targetService == service then
      table.insert(visibleCalls, call)
    end
  end

  local visibleUnits = {}
  for unitId, unit in pairs(dispatchUnits) do
    if unit.service == service then
      visibleUnits[unitId] = unit
    end
  end

  return visibleCalls, visibleUnits
end

local function sendDispatchStateToPlayer(src)
  local calls, units = getVisibleDispatchStateForPlayer(src)
  TriggerClientEvent('funk:dispatch:state', src, calls, units)
end

local function broadcastDispatchUpdate()
  for _, playerId in ipairs(GetPlayers()) do
    sendDispatchStateToPlayer(tonumber(playerId))
  end
end

RegisterNetEvent('funk:setChannel', function(channel)
  local src = source
  local numericChannel = tonumber(channel)

  if not numericChannel then
    TriggerClientEvent('funk:notify', src, 'Ungültiger Kanal.')
    return
  end

  numericChannel = math.floor(numericChannel)

  if numericChannel < Config.MinChannel or numericChannel > Config.MaxChannel then
    TriggerClientEvent('funk:notify', src, ('Kanal muss zwischen %s und %s sein.'):format(Config.MinChannel, Config.MaxChannel))
    return
  end

  local allowed, reason = isAllowedOnChannel(src, numericChannel)
  if not allowed then
    TriggerClientEvent('funk:notify', src, reason or 'Du hast keine Berechtigung für diesen Kanal.')
    return
  end

  playerChannels[src] = numericChannel
  TriggerClientEvent('funk:joinedChannel', src, numericChannel)
end)

RegisterNetEvent('funk:leaveChannel', function()
  local src = source
  playerChannels[src] = nil
  TriggerClientEvent('funk:leftChannel', src)
end)

RegisterNetEvent('funk:dispatch:createCall', function(targetService, message, coords)
  local src = source
  local playerName = getPlayerNameSafe(src)
  local job = getFrameworkJob(src)

  if type(targetService) ~= 'string' or not Config.DispatchServices[targetService] then
    TriggerClientEvent('funk:notify', src, 'Ungültiger Notruf-Typ.')
    return
  end

  message = tostring(message or '')
  message = message:sub(1, 180)

  if message == '' then
    TriggerClientEvent('funk:notify', src, 'Bitte gib einen Notruftext ein.')
    return
  end

  local call = {
    id = nextCallId,
    targetService = targetService,
    message = message,
    callerId = src,
    callerName = playerName,
    callerJob = job,
    coords = coords,
    createdAt = os.time(),
    status = 'offen'
  }

  nextCallId = nextCallId + 1
  table.insert(dispatchCalls, call)

  TriggerClientEvent('funk:notify', src, ('Notruf #%s wurde erstellt.'):format(call.id))

  for _, playerId in ipairs(GetPlayers()) do
    local id = tonumber(playerId)
    local pJob = getFrameworkJob(id)
    local pService = getPlayerService(pJob)
    if pService == targetService then
      TriggerClientEvent('funk:notify', id, ('Neuer Einsatz #%s: %s'):format(call.id, call.message))
    end
  end

  broadcastDispatchUpdate()
end)

RegisterNetEvent('funk:dispatch:requestState', function()
  sendDispatchStateToPlayer(source)
end)


RegisterNetEvent('funk:dispatch:requestContext', function()
  local src = source
  local job = getFrameworkJob(src)
  local service = getPlayerService(job)
  TriggerClientEvent('funk:dispatch:context', src, {
    job = job,
    service = service
  })
end)

RegisterNetEvent('funk:dispatch:occupyUnit', function(unitId)
  local src = source
  local unit = dispatchUnits[unitId]
  if not unit then
    TriggerClientEvent('funk:notify', src, 'Fahrzeug nicht gefunden.')
    return
  end

  local job = getFrameworkJob(src)
  local playerService = getPlayerService(job)

  if playerService ~= unit.service then
    TriggerClientEvent('funk:notify', src, 'Dein Dienst darf dieses Fahrzeug nicht nutzen.')
    return
  end

  if not isJobInList(job, unit.allowedJobs) then
    TriggerClientEvent('funk:notify', src, 'Dein Job darf dieses Fahrzeug nicht besetzen.')
    return
  end

  if unit.occupiedBy and unit.occupiedBy ~= src then
    TriggerClientEvent('funk:notify', src, ('Fahrzeug ist bereits von %s besetzt.'):format(unit.occupiedByName or 'jemandem'))
    return
  end

  unit.occupiedBy = src
  unit.occupiedByName = getPlayerNameSafe(src)

  TriggerClientEvent('funk:notify', src, ('Du hast %s (%s) besetzt.'):format(unit.label, unit.id))
  broadcastDispatchUpdate()
end)

RegisterNetEvent('funk:dispatch:releaseUnit', function(unitId)
  local src = source
  local unit = dispatchUnits[unitId]
  if not unit then
    TriggerClientEvent('funk:notify', src, 'Fahrzeug nicht gefunden.')
    return
  end

  if unit.occupiedBy ~= src then
    TriggerClientEvent('funk:notify', src, 'Du kannst nur dein eigenes Fahrzeug freigeben.')
    return
  end

  unit.occupiedBy = nil
  unit.occupiedByName = nil

  TriggerClientEvent('funk:notify', src, ('Du hast %s (%s) freigegeben.'):format(unit.label, unit.id))
  broadcastDispatchUpdate()
end)

RegisterNetEvent('funk:dispatch:alarmUnit', function(unitId, callId)
  local src = source
  local unit = dispatchUnits[unitId]
  local parsedCallId = tonumber(callId)

  if not unit then
    TriggerClientEvent('funk:notify', src, 'Fahrzeug nicht gefunden.')
    return
  end

  if not parsedCallId then
    TriggerClientEvent('funk:notify', src, 'Ungültige Einsatz-ID.')
    return
  end

  local call
  for _, c in ipairs(dispatchCalls) do
    if c.id == parsedCallId then
      call = c
      break
    end
  end

  if not call then
    TriggerClientEvent('funk:notify', src, 'Einsatz nicht gefunden.')
    return
  end

  local job = getFrameworkJob(src)
  local playerService = getPlayerService(job)

  if not playerService or playerService ~= unit.service or unit.service ~= call.targetService then
    TriggerClientEvent('funk:notify', src, 'Keine Berechtigung für diese Alarmierung.')
    return
  end

  unit.lastAlarmCallId = parsedCallId
  call.status = ('alarmiert: %s'):format(unit.id)

  if unit.occupiedBy then
    TriggerClientEvent('funk:notify', unit.occupiedBy, ('Alarm für %s (%s): Einsatz #%s - %s'):format(unit.label, unit.id, call.id, call.message))
  end

  TriggerClientEvent('funk:notify', src, ('%s (%s) wurde auf Einsatz #%s alarmiert.'):format(unit.label, unit.id, call.id))
  broadcastDispatchUpdate()
end)

RegisterCommand('funkstatus', function(source)
  local channel = playerChannels[source]
  if channel then
    TriggerClientEvent('funk:notify', source, ('Du bist auf Kanal %s.'):format(channel))
  else
    TriggerClientEvent('funk:notify', source, 'Du bist aktuell auf keinem Kanal.')
  end
end, false)

AddEventHandler('playerDropped', function()
  local src = source
  playerChannels[src] = nil

  for _, unit in pairs(dispatchUnits) do
    if unit.occupiedBy == src then
      unit.occupiedBy = nil
      unit.occupiedByName = nil
    end
  end

  broadcastDispatchUpdate()
end)
