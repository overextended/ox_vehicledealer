
local table = lib.table

exports.ox_property:registerZoneMenu('showroom',
	function(currentZone)
		local options = {}
		local propertyVehicles, zoneVehicles = lib.callback.await('ox_property:getVehicleList', 100, {
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
			title = 'Buy Wholesale',
			description = 'Search for a vehicle to import',
			event = 'ox_vehicledealer:buyWholesale',
			args = {
				property = currentZone.property,
				zoneId = currentZone.zoneId,
				restrictions = GlobalState['ShowroomRestrictions'][('%s:%s'):format(currentZone.property, currentZone.zoneId)]
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
				vehicles = propertyVehicles
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
			AddTextEntry('FloatingNotification', ('%s - ~g~$%s'):format(closeVehicle.modelData.name, closeVehicle.modelData.price))
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
			lib.showTextUI(('Plate: %s  \nMake: %s  \nBodyType: %s'):format(veh.plate, veh.modelData.make, veh.modelData.bodytype))
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

			local zoneName = vehicle.stored == 'false' and 'Unknown' or vehicle.stored:gsub('^%l', string.upper)
			if vehicle.stored:find(':') then
				local property, zoneId = string.strsplit(':', vehicle.stored)
				zoneId = tonumber(zoneId)
				if currentZone.property == property and currentZone.zoneId == zoneId then
					zoneName = 'Current Zone'
				elseif properties[property].zones[zoneId] then
					zoneName = string.strconcat(property, ' - ', properties[property].zones[zoneId].name)
				end
			end

			options[('%s - %s'):format(vehicle.modelData.name, vehicle.plate)] = {
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

RegisterNetEvent('ox_vehicledealer:buyWholesale', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		local filters = {'model', 'name', 'make', 'type', 'bodytype', 'class', 'price', 'doors', 'seats', 'weapons'}
		data.filters = data.filters or {}

		local options = {}
		for i = 1, #filters do
			local filter = filters[i]
			if not data.restrictions?[filter]?.hide then
				options[#options + 1] = {
					title =  ('%s: %s'):format(filter:gsub('^%l', string.upper), data.filters?[filter]?.label or 'any'),
					arrow = true,
					event = 'ox_vehicledealer:wholesaleFilter',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						restrictions = data.restrictions,
						filters = data.filters,
						filter = filter
					}
				}
			end
		end

		options[#options + 1] = {
			title = 'Search',
			event = 'ox_vehicledealer:wholesaleResults',
			args = {
				property = currentZone.property,
				zoneId = currentZone.zoneId,
				filters = data.filters
			}
		}

		lib.registerContext({
			id = 'buy_wholesale',
			title = 'Buy Wholesale',
			menu = 'zone_menu',
			options = options
		})
		lib.showContext('buy_wholesale')
	end
end)

RegisterNetEvent('ox_vehicledealer:wholesaleFilter', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		local restriction = data.restrictions[data.filter]
		if data.filter == 'model' or data.filter == 'name' then
			local input = lib.inputDialog('Search Term', {data.filter:gsub('^%l', string.upper)})
			if input then
				data.filters[data.filter] = {label = input[1], value = input[1]}
			else
				data.filters[data.filter] = nil
			end
			Wait(100)
			TriggerEvent('ox_vehicledealer:buyWholesale', data)
		elseif data.filter == 'price' or data.filter == 'doors' or data.filter == 'seats' then
			local range = GlobalState['VehicleFilters'][data.filter]
			if restriction then
				if restriction.allow then
					range = {
						restriction.data[1] > range[1] and restriction.data[1] or range[1],
						restriction.data[2] < range[2] and restriction.data[2] or range[2]
					}
				else
					if (restriction.data[1] - range[1]) > 0 and (range[2] - restriction.data[2]) > 0 then
						range = {
							range[1],
							range[2],
							restriction.data[1],
							restriction.data[2],
						}
					else
						range = {
							restriction.data[1] == range[1] and restriction.data[2] or range[1],
							restriction.data[2] == range[2] and restriction.data[1] or range[2]
						}
					end
				end
			end

			local str = data.filter == 'price' and '$%s - $%s' or '%s - %s'
			local label = str:format(range[1], range[2])
			if range[3] and range[4] then
				label = str:format(range[1], range[3]) .. ', ' .. str:format(range[4], range[2])
			end

			local input = lib.inputDialog(data.filter:gsub('^%l', string.upper) .. ' range ' .. label, {'Low', 'High'})
			if input then
				input[1] = tonumber(input[1])
				input[2] = tonumber(input[2])

				if input[1] then
					if input[1] < range[1] then
						input[1] = nil
					elseif input[1] > range[2] then
						input[1] = range[2]
					end
				end

				if input[2] then
					if input[2] > range[2] then
						input[2] = nil
					elseif input[2] < range[1] then
						input[2] = range[1]
					end
				end

				if input[1] and input[2] and input[1] > input[2] then
					data.filters[data.filter] = nil
					lib.notify({title = 'Input invalid', type = 'error'})
				elseif input[1] or input[2] then
					input[1] = input[1] or range[1]
					input[2] = input[2] or range[2]
					data.filters[data.filter] = {label = str:format(input[1], input[2]), value = {input[1], input[2]}}
				else
					data.filters[data.filter] = nil
				end
			else
				data.filters[data.filter] = nil
			end
			Wait(100)
			TriggerEvent('ox_vehicledealer:buyWholesale', data)
		else
			local available = data.filter == 'weapons' and {'yes', 'no'} or GlobalState['VehicleFilters'][data.filter]

			local filters = table.deepclone(data.filters)
			filters[data.filter] = nil

			local options = {
				{
					title = 'Any',
					event = 'ox_vehicledealer:buyWholesale',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						restrictions = data.restrictions,
						filters = filters
					}
				}
			}

			for i = data.filter == 'class' and 0 or 1, #available do
				local item = data.filter == 'class' and i or available[i]
				if restriction then
					if restriction.allow then
						if (type(restriction.data) == 'table' and not table.contains(restriction.data, item)) or (type(restriction.data) ~= 'table' and restriction.data ~= item) then
							item = nil
						end
					else
						if (type(restriction.data) == 'table' and table.contains(restriction.data, item)) or (type(restriction.data) ~= 'table' and restriction.data == item) then
							item = nil
						end
					end
				end

				if item then
					local args = table.deepclone(data)
					args.property = currentZone.property
					args.zoneId = currentZone.zoneId

					item = data.filter == 'class' and available[i] or item
					if data.filter == 'class' then
						args.filters[data.filter] = {label = item, value = i}
					elseif data.filter == 'weapons' then
						args.filters[data.filter] = {label = item, value = item == 'yes'}
					else
						args.filters[data.filter] = {label = item, value = item}
					end

					options[#options + 1] = {
						title = item:gsub('^%l', string.upper),
						event = 'ox_vehicledealer:buyWholesale',
						args = args
					}
				end
			end

			lib.registerContext({
				id = 'filter_menu',
				title = data.filter:gsub('^%l', string.upper),
				menu = 'buy_wholesale',
				options = options
			})
			lib.showContext('filter_menu')
		end
	end
end)

RegisterNetEvent('ox_vehicledealer:wholesaleResults', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		for k, v in pairs(data.filters) do
			data.filters[k] = v.value
		end
		local vehicles = lib.callback.await('ox_vehicledealer:getWholesaleVehicles', 100, data)

		local options = {}
		for i = 1, #vehicles do
			local vehicle = vehicles[i]
			options[#options + 1] = {
				title = vehicle.name,
				description = ('$%s'):format(vehicle.price),
				serverEvent = 'ox_vehicledealer:buyWholesale',
				args = {
					property = currentZone.property,
					zoneId = currentZone.zoneId,
					model = vehicle.model,
					type = vehicle.type
				},
				metadata = {
					Type = vehicle.type,
					Bodytype = vehicle.bodytype,
					Make = vehicle.make,
				}
			}
		end
		lib.registerContext({
			id = 'wholesale_results',
			title = 'Purchase Vehicle',
			menu = 'buy_wholesale',
			options = options
		})
		lib.showContext('wholesale_results')
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
		if data.rotate then
			TriggerServerEvent('ox_vehicledealer:moveVehicle', data)
		else
			data.entities = exports.ox_property:getZoneEntities()
			TriggerServerEvent('ox_vehicledealer:moveVehicle', data)
		end
	end
end)

RegisterNetEvent('ox_vehicledealer:buyVehicle', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		lib.hideTextUI()
		TriggerServerEvent('ox_vehicledealer:buyVehicle', data)
	end
end)

RegisterCommand('testui', function()
	SendNUIMessage({
		action = 'setVisible',
		data = true
	})
	SetNuiFocus(true, true)
end)