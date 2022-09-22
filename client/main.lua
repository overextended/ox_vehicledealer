
local table = lib.table

lib.locale()

exports.ox_property:registerZoneMenu('showroom',
	function(currentZone)
		local options = {}
		local propertyVehicles, zoneVehicles, vehicleData = lib.callback.await('ox_property:getVehicleList', 100, {
			property = currentZone.property,
			zoneId = currentZone.zoneId,
			propertyOnly = true
		})

		if cache.seat == -1 then
			options[#options + 1] = {
				title = 'Store Vehicle',
				event = 'ox_property:storeVehicle',
				args = {
					property = currentZone.property,
					zoneId = currentZone.zoneId
				}
			}
			local vehicle = GlobalState['DisplayedVehicles'][GetVehicleNumberPlateText(cache.vehicle)]
			if vehicle then
				options[#options + 1] = {
					title = 'Move Vehicle',
					event = 'ox_vehicledealer:moveVehicle',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId
					}
				}
				options[#options + 1] = {
					title = 'Rotate Vehicle',
					event = 'ox_vehicledealer:moveVehicle',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						rotate = true
					}
				}
				options[#options + 1] = {
					title = 'Buy Vehicle',
					event = 'ox_vehicledealer:buyVehicle',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId
					}
				}
			end
		end

		options[#options + 1] = {
			title = 'Wholesale Menu',
			description = 'Choose a vehicle to import',
			event = 'ox_vehicledealer:buyWholesale',
			args = {
				property = currentZone.property,
				zoneId = currentZone.zoneId
			}
		}

		if zoneVehicles[1] then
			options[#options + 1] = {
				title = 'Open Showroom',
				description = 'View your vehicles at this showroom',
				metadata = {['Vehicles'] = #zoneVehicles},
				event = 'ox_vehicledealer:vehicleList',
				args = {
					property = currentZone.property,
					zoneId = currentZone.zoneId,
					vehicles = zoneVehicles,
					vehicleData = vehicleData,
					zoneOnly = true
				}
			}
		end

		options[#options + 1] = {
			title = 'Property Vehicles',
			description = 'View all your vehicles stored at this property',
			metadata = {['Vehicles'] = #propertyVehicles}
		}
		if #propertyVehicles > 0 then
			options[#options].event = 'ox_vehicledealer:vehicleList'
			options[#options].args = {
				property = currentZone.property,
				zoneId = currentZone.zoneId,
				vehicles = propertyVehicles,
				vehicleData = vehicleData
			}
		end

		return options
	end
)

exports.ox_property:registerZoneMenu('import/export',
	function(currentZone)
		local options = {}

		if cache.seat == -1 then
			options[#options + 1] = {
				title = 'Sell Vehicle',
				event = 'ox_vehicledealer:sellWholesale',
				args = {
					property = currentZone.property,
					zoneId = currentZone.zoneId
				}
			}
		elseif not cache.vehicle then
			options[#options + 1] = {
				title = 'Buy Vehicles',
				description = 'Choose a vehicle to import',
				event = 'ox_vehicledealer:buyWholesale',
				args = {
					property = currentZone.property,
					zoneId = currentZone.zoneId
				}
			}
		end

		return options
	end
)

local displayedVehicles = GlobalState['DisplayedVehicles']
CreateThread(function()
	while true do
		Wait(0)
		local closeDist, closeVehicle = 7.5
		local pedPos = GetEntityCoords(cache.ped)
		for k, v in pairs(displayedVehicles) do
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
			AddTextEntry('FloatingNotification', ('%s - ~g~$%s'):format(closeVehicle.data.name, closeVehicle.data.price))
			EndTextCommandDisplayHelp(2, false, false, -1)
			SetFloatingHelpTextWorldPosition(1, closeVehicle.vehPos.x, closeVehicle.vehPos.y, closeVehicle.vehPos.z + 1)
			SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
		end
	end
end)

AddStateBagChangeHandler('DisplayedVehicles', 'global', function(bagName, key, value, reserved, replicated)
	displayedVehicles = value
end)

lib.onCache('vehicle', function(vehicle)
	if vehicle then
		local veh = displayedVehicles[GetVehicleNumberPlateText(vehicle)]
		if veh then
			lib.showTextUI(('Plate: %s  \nMake: %s  \nType: %s'):format(veh.plate, veh.data.make, veh.data.type))
		end
	else
		lib.hideTextUI()
	end
end)

RegisterNetEvent('ox_vehicledealer:vehicleList', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		local properties = GlobalState['Properties']
		local options = {}
		local subMenus = {}
		for i = 1, #data.vehicles do
			local vehicle = data.vehicles[i]
			vehicle.data = data.vehicleData[vehicle.model]

			local zoneName = vehicle.stored == 'false' and 'Unknown' or vehicle.stored:gsub('^%l', string.upper)
			if vehicle.stored:find(':') then
				local property, zoneId = string.strsplit(':', vehicle.stored)
				zoneId = tonumber(zoneId)
				if currentZone.property == property and currentZone.zoneId == zoneId then
					zoneName = 'Current Zone'
				elseif properties[property].zones[zoneId] then
					zoneName = ('%s - %s'):format(property, properties[property].zones[zoneId].name)
				end
			end

			options[('%s - %s'):format(vehicle.data.name, vehicle.plate)] = {
				menu = vehicle.plate,
				metadata = {['Location'] = zoneName}
			}

			local subOptions = {}
			if vehicle.stored == ('%s:%s'):format(data.property, data.zoneId) then
				subOptions['Display'] = {
					event = 'ox_vehicledealer:displayVehicle',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						plate = vehicle.plate
					}
				}
				subOptions['Retrieve'] = {
					event = 'ox_property:retrieveVehicle',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						plate = vehicle.plate
					}
				}
				subOptions['Sell Wholesale'] = {
					serverEvent = 'ox_vehicledealer:sellWholesale',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						plate = vehicle.plate
					}
				}
			else
				subOptions['Move'] = {
					serverEvent = 'ox_property:moveVehicle',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						plate = vehicle.plate
					}
				}
			end
			subMenus[#subMenus + 1] = {
				id = vehicle.plate,
				title = vehicle.plate,
				menu = 'vehicle_list',
				options = subOptions
			}
		end

		local menu = {
			id = 'vehicle_list',
			title = data.zoneOnly and ('%s - %s - Vehicles'):format(currentZone.property, currentZone.name) or ('%s - Vehicles'):format(currentZone.property),
			menu = 'zone_menu',
			options = options
		}
		for i = 1, #subMenus do
			menu[i] = subMenus[i]
		end

		lib.registerContext(menu)
		lib.showContext('vehicle_list')
	end
end)

local categories = GlobalState['VehicleClasses']
local displayVehicle = {}

RegisterNetEvent('ox_vehicledealer:buyWholesale', function(data)
	local currentZone = exports.ox_property:getCurrentZone()

	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		SendNUIMessage({
			action = 'setVisible',
			data = {
				visible = true,
				categories = categories
			}
		})

		SetNuiFocus(true, true)
		SetNuiFocusKeepInput(true)
		NetworkStartSoloTutorialSession()
		SetPlayerInvincible(cache.playerId, true)

		local interiorId = GetInteriorFromEntity(cache.ped)
		cache.coords = GetEntityCoords(cache.ped)
		displayVehicle.coords = interiorId == 0 and cache.coords or vec3(GetInteriorPosition(interiorId))

		while displayVehicle.coords do
			DisableAllControlActions(0)

			if IsDisabledControlPressed(0, 25) then
				EnableControlAction(0, 0, true)
				EnableControlAction(0, 1, true)
				EnableControlAction(0, 2, true)
			end

			Wait(0)
		end
	end
end)

RegisterNetEvent('ox_vehicledealer:displayVehicle', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		data.entities = exports.ox_property:getZoneEntities()
		TriggerServerEvent('ox_vehicledealer:displayVehicle', data)
	end
end)

RegisterNetEvent('ox_vehicledealer:moveVehicle', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		if not data.rotate then
			data.entities = exports.ox_property:getZoneEntities()
		end
		TriggerServerEvent('ox_vehicledealer:moveVehicle', data)
	end
end)

RegisterNetEvent('ox_vehicledealer:buyVehicle', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		lib.hideTextUI()
		TriggerServerEvent('ox_vehicledealer:buyVehicle', data)
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

RegisterNUICallback('cameraMouseDown', function(_, cb)
	cb(1)
end)

RegisterNUICallback('cameraMouseUp', function (_, cb)
	cb(1)
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

---@param str string
---@return vector3
local function rgbToVector(str)
	local r, g, b = string.strsplit(',', str:sub(5, -2))
	return vec3(tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0)
end

RegisterNUICallback('changeColor', function(data, cb)
	cb(1)

	if data[1] ~= '' then
		displayVehicle.primary = rgbToVector(data[1])
		SetVehicleCustomPrimaryColour(displayVehicle.entity, displayVehicle.primary.x, displayVehicle.primary.y, displayVehicle.primary.z)
	end

	if data[2] ~= '' then
		displayVehicle.secondary = rgbToVector(data[2])
		SetVehicleCustomSecondaryColour(displayVehicle.entity, displayVehicle.secondary.x, displayVehicle.secondary.y, displayVehicle.secondary.z)
	end
end)

local function closeUi(_, cb)
	if cb then cb(1) end

	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)

	if displayVehicle.entity then
		SetModelAsNoLongerNeeded(GetEntityModel(displayVehicle.entity))
		SetVehicleAsNoLongerNeeded(displayVehicle.entity)
		DeleteEntity(displayVehicle.entity)
		SetEntityCoordsNoOffset(cache.ped, cache.coords.x, cache.coords.y, cache.coords.z, true, false, false)
	end

	table.wipe(displayVehicle)
	NetworkEndTutorialSession()
	SetPlayerInvincible(cache.playerId, false)
end

RegisterNUICallback('purchaseVehicle', function(data, cb)
	cb(1)
	local currentZone = exports.ox_property:getCurrentZone()
	local primary, secondary = GetVehicleColours(displayVehicle.entity)

    local livery = GetVehicleLivery(displayVehicle.entity)
    if livery == -1 then
        livery = GetVehicleMod(displayVehicle.entity, 48)
    end
    local roofLivery = GetVehicleRoofLivery(displayVehicle.entity)

    TriggerServerEvent('ox_vehicledealer:buyWholesale', {
		property = currentZone.property,
		zoneId = currentZone.zoneId,
		model = data.model,
		color1 = displayVehicle.primary and { displayVehicle.primary.x, displayVehicle.primary.y, displayVehicle.primary.z } or primary,
		color2 = displayVehicle.secondary and { displayVehicle.secondary.x, displayVehicle.secondary.y, displayVehicle.secondary.z } or secondary,
        livery = livery,
        roofLivery = roofLivery
	})

	closeUi()
end)

RegisterNUICallback('clickVehicle', function(data, cb)
	cb(1)

	if displayVehicle.entity then
		SetModelAsNoLongerNeeded(GetEntityModel(displayVehicle.entity))
		SetVehicleAsNoLongerNeeded(displayVehicle.entity)
		DeleteEntity(displayVehicle.entity)
	end

	local hash = joaat(data.model)

	if not HasModelLoaded(hash) then
		RequestModel(hash)
		repeat Wait(0) until HasModelLoaded(hash)
	end

	displayVehicle.entity = CreateVehicle(hash, displayVehicle.coords.x, displayVehicle.coords.y, displayVehicle.coords.z + 1.0, 90.0, false, false)
	SetVehicleOnGroundProperly(displayVehicle.entity)
	SetPedIntoVehicle(cache.ped, displayVehicle.entity, -1)
	FreezeEntityPosition(displayVehicle.entity, true)
    SetVehicleMod(displayVehicle.entity, 48, -1, false)
    SetVehicleLivery(displayVehicle.entity, 0)
    SetVehicleRoofLivery(displayVehicle.entity, 0)
	SetEntityCollision(displayVehicle.entity, false, false)
end)

local vehicleCategories = GlobalState['VehicleClasses']
RegisterNUICallback('fetchVehicles', function(data, cb)
	local class = nil
	for i = 1, #vehicleCategories do
		if vehicleCategories[i] == data.category then
			class = i - 1 -- classes start from 0, like arrays should
			break
		end
	end
	vehicles = lib.callback.await('ox_vehicledealer:fetchVehicles', false, class)
	cb(vehicles)
end)

RegisterNUICallback('exit', closeUi)
