local currentChannel = nil
local dispatchCalls = {}
local dispatchUnits = {}
local playerContext = { job = nil, service = nil }

local function setVoiceChannel(channel)
  if GetResourceState('pma-voice') == 'started' and exports['pma-voice'] then
    exports['pma-voice']:setRadioChannel(channel)
    exports['pma-voice']:setVoiceProperty('radioEnabled', channel > 0)
    return true
  end

  return Config.AllowFallbackWithoutVoiceExport
end

local function keyboardInput(title, defaultText, maxLength)
  AddTextEntry('FUNK_INPUT', title)
  DisplayOnscreenKeyboard(1, 'FUNK_INPUT', '', defaultText or '', '', '', '', maxLength or 128)

  while UpdateOnscreenKeyboard() == 0 do
    Wait(0)
  end

  if UpdateOnscreenKeyboard() == 1 then
    return GetOnscreenKeyboardResult()
  end

  return nil
end

local function notify(message)
  BeginTextCommandThefeedPost('STRING')
  AddTextComponentSubstringPlayerName(('[FUNK] %s'):format(message))
  EndTextCommandThefeedPostTicker(false, false)
end

local function printDispatchOverview()
  TriggerEvent('chat:addMessage', {
    color = { 0, 200, 255 },
    args = { 'Leitstelle', '--- Sichtbare Einsätze ---' }
  })

  if #dispatchCalls == 0 then
    TriggerEvent('chat:addMessage', { color = { 180, 180, 180 }, args = { 'Leitstelle', 'Keine Einsätze sichtbar.' } })
  else
    for _, call in ipairs(dispatchCalls) do
      TriggerEvent('chat:addMessage', {
        color = { 255, 255, 255 },
        args = { 'Leitstelle', ('#%s %s | Status: %s'):format(call.id, call.message, call.status or 'offen') }
      })
    end
  end

  TriggerEvent('chat:addMessage', {
    color = { 0, 200, 255 },
    args = { 'Leitstelle', '--- Fahrzeuge ---' }
  })

  local hasUnits = false
  for _, unit in pairs(dispatchUnits) do
    hasUnits = true
    local occupiedText = unit.occupiedByName and ('besetzt von ' .. unit.occupiedByName) or 'frei'
    TriggerEvent('chat:addMessage', {
      color = { 255, 255, 255 },
      args = { 'Leitstelle', ('%s (%s) - %s'):format(unit.label, unit.id, occupiedText) }
    })
  end

  if not hasUnits then
    TriggerEvent('chat:addMessage', { color = { 180, 180, 180 }, args = { 'Leitstelle', 'Keine Fahrzeuge sichtbar.' } })
  end
end

local function createPublicCallFlow()
  local targetChoice = keyboardInput('Notruf: 1=Polizei, 2=Feuerwehr/RD', '', 1)
  if not targetChoice then
    notify('Notruf abgebrochen.')
    return
  end

  local targetService = nil
  if targetChoice == '1' then
    targetService = 'police'
  elseif targetChoice == '2' then
    targetService = 'fire_ems'
  else
    notify('Ungültige Auswahl.')
    return
  end

  local text = keyboardInput('Notruftext eingeben', '', 180)
  if not text or text == '' then
    notify('Notruf abgebrochen.')
    return
  end

  local coords = GetEntityCoords(PlayerPedId())
  TriggerServerEvent('funk:dispatch:createCall', targetService, text, { x = coords.x, y = coords.y, z = coords.z })
end

local function openLeitstelleFlow()
  TriggerServerEvent('funk:dispatch:requestContext')
  TriggerServerEvent('funk:dispatch:requestState')
  Wait(200)

  if not playerContext.service then
    notify('Du hast keinen Leitstellen-Job. Du kannst aber einen Notruf mit F10 -> 1 senden.')
    return
  end

  local option = keyboardInput('Leitstelle: 1=Einsätze/Fahrzeuge, 2=Fahrzeug besetzen, 3=Fahrzeug freigeben, 4=Fahrzeug alarmieren', '', 1)
  if not option then
    notify('Leitstelle geschlossen.')
    return
  end

  if option == '1' then
    printDispatchOverview()
    return
  end

  if option == '2' then
    local unitId = keyboardInput('Fahrzeug-ID zum Besetzen (z.B. F-11)', '', 10)
    if unitId and unitId ~= '' then
      TriggerServerEvent('funk:dispatch:occupyUnit', unitId)
    else
      notify('Abgebrochen.')
    end
    return
  end

  if option == '3' then
    local unitId = keyboardInput('Fahrzeug-ID zum Freigeben', '', 10)
    if unitId and unitId ~= '' then
      TriggerServerEvent('funk:dispatch:releaseUnit', unitId)
    else
      notify('Abgebrochen.')
    end
    return
  end

  if option == '4' then
    local unitId = keyboardInput('Fahrzeug-ID (z.B. P-31)', '', 10)
    local callId = keyboardInput('Einsatz-ID (z.B. 1)', '', 6)
    if unitId and unitId ~= '' and callId and tonumber(callId) then
      TriggerServerEvent('funk:dispatch:alarmUnit', unitId, tonumber(callId))
    else
      notify('Ungültige Eingabe.')
    end
    return
  end

  notify('Unbekannte Option.')
end

RegisterNetEvent('funk:notify', function(message)
  notify(message)
end)

RegisterNetEvent('funk:joinedChannel', function(channel)
  if setVoiceChannel(channel) then
    currentChannel = channel
    notify(('Du bist Kanal %s beigetreten.'):format(channel))
  else
    notify('Kein unterstütztes Voice-System gefunden.')
  end
end)

RegisterNetEvent('funk:leftChannel', function()
  if setVoiceChannel(0) then
    currentChannel = nil
    notify('Du hast den Funkkanal verlassen.')
  else
    notify('Kein unterstütztes Voice-System gefunden.')
  end
end)

RegisterNetEvent('funk:dispatch:context', function(ctx)
  playerContext = ctx or { job = nil, service = nil }
end)

RegisterNetEvent('funk:dispatch:state', function(calls, units)
  dispatchCalls = calls or {}
  dispatchUnits = units or {}
end)

RegisterCommand('funk', function(_, args)
  local sub = args[1]

  if not sub then
    TriggerEvent('chat:addMessage', {
      color = { 255, 255, 0 },
      multiline = true,
      args = { 'Funk', '/funk join <kanal> | /funk leave | /funk status' }
    })
    return
  end

  sub = string.lower(sub)

  if sub == 'join' then
    local channel = tonumber(args[2])
    if not channel then
      notify('Nutze: /funk join <kanal>')
      return
    end

    TriggerServerEvent('funk:setChannel', channel)
    return
  end

  if sub == 'leave' then
    TriggerServerEvent('funk:leaveChannel')
    return
  end

  if sub == 'status' then
    if currentChannel then
      notify(('Aktueller Kanal: %s'):format(currentChannel))
    else
      notify('Du bist auf keinem Kanal.')
    end
    return
  end

  notify('Unbekannter Unterbefehl.')
end, false)

RegisterCommand('notruf', function(_, args)
  local target = args[1]
  if not target then
    notify('Nutze: /notruf police <text> oder /notruf fire_ems <text>')
    return
  end

  local text = table.concat(args, ' ', 2)
  if text == '' then
    text = keyboardInput('Notruftext eingeben', '', 180)
  end

  if not text or text == '' then
    notify('Notruf abgebrochen.')
    return
  end

  local coords = GetEntityCoords(PlayerPedId())
  TriggerServerEvent('funk:dispatch:createCall', target, text, { x = coords.x, y = coords.y, z = coords.z })
end, false)

RegisterCommand('leitstelle', function()
  openLeitstelleFlow()
end, false)

RegisterCommand('+openFunkMenu', function()
  local choice = keyboardInput('F10 Menü: 1=Notruf senden, 2=Leitstelle öffnen', '', 1)
  if not choice then
    return
  end

  if choice == '1' then
    createPublicCallFlow()
    return
  end

  if choice == '2' then
    openLeitstelleFlow()
    return
  end

  notify('Ungültige Auswahl.')
end, false)

RegisterCommand('-openFunkMenu', function()
end, false)

RegisterKeyMapping('+openFunkMenu', 'Funk/Leitstellen Menü öffnen', 'keyboard', 'F10')

CreateThread(function()
  Wait(2000)
  TriggerServerEvent('funk:dispatch:requestContext')
  TriggerServerEvent('funk:dispatch:requestState')
end)
