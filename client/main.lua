DisplayedVehicles = GlobalState['DisplayedVehicles']
DisplayVehicle = {}

VehicleData = setmetatable({}, {
	__index = function(self, index)
		local data = Ox.GetVehicleData(index)

		if data then
			data = {
				name = data.name,
				price = data.price,
			}

			self[index] = data
			return data
		end
	end
})

lib.locale()

function SetStatsUi(data)
    SendNUIMessage({
        action = 'setStatsVisible',
        data = data
    })
end

CreateThread(function()
    while true do
        Wait(0)
        local closeDist, closeVehicle = 7.5
        local pedPos = GetEntityCoords(cache.ped)
        for k, v in pairs(DisplayedVehicles) do
            if NetworkDoesEntityExistWithNetworkId(v.netid) then
                v.vehPos = GetEntityCoords(NetToVeh(v.netid))
                local distance = #(pedPos - v.vehPos)
                if closeDist > distance then
                    closeDist = distance
                    closeVehicle = v
                end
            end
        end

        if closeVehicle then
            BeginTextCommandDisplayHelp('FloatingNotification')
            AddTextEntry('FloatingNotification', ('%s - ~g~$%s'):format(closeVehicle.name, closeVehicle.price))
            EndTextCommandDisplayHelp(2, false, false, -1)
            SetFloatingHelpTextWorldPosition(1, closeVehicle.vehPos.x, closeVehicle.vehPos.y, closeVehicle.vehPos.z + 1)
            SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
        end
    end
end)

AddStateBagChangeHandler('DisplayedVehicles', 'global', function(bagName, key, value, reserved, replicated)
    DisplayedVehicles = value
end)

lib.onCache('vehicle', function(vehicle)
    if vehicle then
        local veh = DisplayedVehicles[GetVehicleNumberPlateText(vehicle)]
        if veh then
            SetStatsUi({veh.model, veh.price})
        end
    else
        SetStatsUi(false)
    end
end)

-- Changes the locales in UI on locale change
RegisterNetEvent('ox_lib:setLocale', function(locale)
    local resource = GetCurrentResourceName()
    local JSON = LoadResourceFile(resource, ('locales/%s.json'):format(locale)) or LoadResourceFile(resource, ('locales/en.json'):format(locale))
    SendNUIMessage({
        action = 'setLocale',
        data = json.decode(JSON)
    })
end)

-- Loads the locales into UI on startup
RegisterNUICallback('loadLocale', function(_, cb)
    cb(1)
    local resource = GetCurrentResourceName()
    local locale = GetExternalKvpString('ox_lib', 'locale') or 'en'
    local JSON = LoadResourceFile(resource, ('locales/%s.json'):format(locale)) or LoadResourceFile(resource, ('locales/en.json'):format(locale))
    SendNUIMessage({
        action = 'setLocale',
        data = json.decode(JSON)
    })
end)

function CloseUi(_, cb)
    if cb then cb(1) end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    if DisplayVehicle.entity then
        SetModelAsNoLongerNeeded(GetEntityModel(DisplayVehicle.entity))
        SetVehicleAsNoLongerNeeded(DisplayVehicle.entity)
        DeleteEntity(DisplayVehicle.entity)
        SetEntityCoordsNoOffset(cache.ped, cache.coords.x, cache.coords.y, cache.coords.z, true, false, false)
    end

    table.wipe(DisplayVehicle)
    NetworkEndTutorialSession()
    SetPlayerInvincible(cache.playerId, false)
end

RegisterNUICallback('exit', CloseUi)
