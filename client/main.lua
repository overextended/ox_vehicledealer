
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
			local vehicle = GlobalState['DisplayedVehicles'][VehToNet(cache.vehicle)]
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
		local netid = VehToNet(vehicle)
		local veh = displayedVehicles[netid]
		if veh then
			lib.showTextUI(('Plate: %s  \nMake: %s  \nBodyType: %s  \n'):format(veh.plate, veh.modelData.make, veh.modelData.bodytype))
		end
	else
		lib.hideTextUI()
	end
end)

RegisterNetEvent('ox_vehicledealer:vehicleList', function(data)
	local currentZone = exports.ox_property:getCurrentZone()
	if currentZone.property == data.property and currentZone.zoneId == data.zoneId then
		local options = {}
		local subMenus = {}
		for i = 1, #data.vehicles do
			local vehicle = data.vehicles[i]
			options[('%s - %s'):format(vehicle.modelData.name, vehicle.plate)] = {
				menu = vehicle.plate,
				metadata = {['Location'] = vehicle.stored}
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
			options[#options + 1] = {
				title =  ('%s: %s'):format(filter:gsub('^%l', string.upper), data.filters?[filter]?.label or 'any'),
				arrow = true,
				event = 'ox_vehicledealer:wholesaleFilter',
				args = {
					property = currentZone.property,
					zoneId = currentZone.zoneId,
					filters = data.filters,
					filter = filter
				}
			}
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
		if data.filter == 'model' or data.filter == 'name' then
			local input = lib.inputDialog('Search Term', {data.filter:gsub('^%l', string.upper)})
			if input then
				data.filters[data.filter] = {label = input[1], value = input[1]}
			else
				data.filters[data.filter] = nil
			end
			Wait(100)
			TriggerEvent('ox_vehicledealer:buyWholesale', data)
		elseif table.contains({'make', 'type', 'bodytype', 'class', 'weapons'}, data.filter) then
			local available
			if data.filter == 'weapons' then
				available = {'yes', 'no'}
			else
				available = GlobalState['VehicleFilters'][data.filter]
			end

			local filters = table.deepclone(data.filters)
			filters[data.filter] = nil

			local options = {
				{
					title = 'Any',
					event = 'ox_vehicledealer:buyWholesale',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						filters = filters
					}
				}
			}

			for i = 1, #available do
				local item = available[i]

				local args = table.deepclone(data)
				args.property = currentZone.property
				args.zoneId = currentZone.zoneId

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

			lib.registerContext({
				id = 'filter_menu',
				title = data.filter:gsub('^%l', string.upper),
				menu = 'buy_wholesale',
				options = options
			})
			lib.showContext('filter_menu')
		elseif data.filter == 'price' or data.filter == 'doors' or data.filter == 'seats' then
			local range = GlobalState['VehicleFilters'][data.filter]
			local str = data.filter == 'price' and '$%s - $%s' or '%s - %s'
			local input = lib.inputDialog(data.filter:gsub('^%l', string.upper) .. ' range ' .. str:format(range[1], range[2]), {'Low', 'High'})
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
