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
            AddTextEntry('FloatingNotification', ('%s - ~g~$%s'):format(VehicleData[closeVehicle.model]?.name, closeVehicle.price))
            EndTextCommandDisplayHelp(2, false, false, -1)
            SetFloatingHelpTextWorldPosition(1, closeVehicle.vehPos.x, closeVehicle.vehPos.y, closeVehicle.vehPos.z + 1)
            SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
        end
    end
end)

AddStateBagChangeHandler('DisplayedVehicles', 'global', function(bagName, key, value, reserved, replicated)
    DisplayedVehicles = value
end)

AddStateBagChangeHandler('frozen', '', function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)

    SetVehicleHandbrake(entity, value)

    if value then
        SetVehicleOnGroundProperly(entity)
    end
end)

lib.onCache('vehicle', function(vehicle)
    if vehicle then
        local displayedVehicle
        local plate = GetVehicleNumberPlateText(vehicle)

        for _, veh in pairs(DisplayedVehicles) do
            if veh.plate == plate then
                displayedVehicle = veh
                break
            end
        end

        if displayedVehicle then
            SetStatsUi({displayedVehicle.model, displayedVehicle.price})
        end
    else
        SetStatsUi(false)
    end
end)

RegisterNUICallback('getBlacklistedVehicles', function(_, cb)
    cb(ImportBlacklist)
end)

-- Loads the locales into UI on startup
RegisterNUICallback('loadLocale', function(_, cb)
    cb(1)
    local resource = GetCurrentResourceName()
    local locale = GetConvar('ox:locale', 'en')
    local JSON = LoadResourceFile(resource, ('locales/%s.json'):format(locale)) or LoadResourceFile(resource, 'locales/en.json')
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
