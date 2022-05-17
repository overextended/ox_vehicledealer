
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
		end

		options[#options + 1] = {
			title = 'Buy Wholesale',
			description = 'Find a vehicle to buy import',
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
					freeze = true
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
					event = 'ox_property:retrieveVehicle',
					args = {
						property = currentZone.property,
						zoneId = currentZone.zoneId,
						plate = vehicle.plate,
						freeze = true
					}
				}
				subOptions['Sell Wholesale'] = {}
			elseif vehicle.stored:find(':') then
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
			title = data.zoneOnly and ('%s - %s - Vehicles'):format(currentZone.property, currentZone.name) or 'All Vehicles',
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
				serverEvent ='ox_vehicledealer:spawnVehicle',
				args = vehicle.model,
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