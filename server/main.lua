local table = lib.table
local filterCount = {}
local showroomRestrictions = {}

local function registerRestrictions(zone)
	zone.restrictions.allow.type = {}
	for k, v in pairs(zone.vehicles) do
		zone.restrictions.allow.type[#zone.restrictions.allow.type + 1] = k
	end

	local restrictions = {}
	for k, v in pairs(zone.restrictions.allow) do
		local hide = false
		if k == 'price' or k == 'doors' or k == 'seats' then
			hide = (v[2] - v[1]) < 2
		elseif k == 'weapons' then
			hide = true
		elseif k ~= 'model' and k ~= 'name' then
			hide = #v < 2
		end

		restrictions[k] = {
			allow = true,
			hide = hide,
			data = v
		}
		if zone.restrictions.deny[k] then
			zone.restrictions.deny[k] = nil
		end
	end

	for k, v in pairs(zone.restrictions.deny) do
		local hide = false
		if k == 'price' or k == 'doors' or k == 'seats' then
			hide = (filterCount[k] - (v[2] - v[1])) < 2
		elseif k == 'weapons' then
			hide = true
		elseif k ~= 'model' and k ~= 'name' then
			hide = (filterCount[k] - #v) < 2
		end

		restrictions[k] = {
			allow = false,
			hide = hide,
			data = v
		}
	end

	return restrictions
end

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		exports.ox_property:loadDataFiles()

		local displayedVehicles = MySQL.query.await('SELECT owner, data, x, y, z, heading FROM vehicles WHERE stored = "displayed"')

		local vehicles = {}
		for i = 1, #displayedVehicles do
			local vehicle = displayedVehicles[i]
			vehicle.data = json.decode(vehicle.data)

			local veh = Ox.CreateVehicle(vehicle.owner, vehicle.data, vec(vehicle.x, vehicle.y, vehicle.z, vehicle.heading))
			veh.modelData = exports.ox_property:getModelData(veh.data.model)
			vehicles[veh.plate] = veh
		end

		GlobalState['DisplayedVehicles'] = vehicles

		Wait(1000)
		for k, v in pairs(vehicles) do
			FreezeEntityPosition(v.entity, true)
		end

		local vehicleFilters = GlobalState['VehicleFilters']

		for k, v in pairs(vehicleFilters) do
			if k == 'price' or k == 'doors' or k == 'seats' then
				filterCount[k] = v[2] - v[1]
			elseif k == 'class' then
				filterCount[k] = #v + 1
			else
				filterCount[k] = #v
			end
		end

		local properties = GlobalState['Properties']
		for k, v in pairs(properties) do
			if v.zones then
				for i = 1, #v.zones do
					local zone = v.zones[i]
					if zone.type == 'showroom' and zone.restrictions then
						showroomRestrictions[('%s:%s'):format(k, i)] = registerRestrictions(zone)
					end
				end
			end
		end

		GlobalState['ShowroomRestrictions'] = showroomRestrictions
	end
end)

lib.callback.register('ox_vehicledealer:getWholesaleVehicles', function(source, data)
	local player = lib.getPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	local query = {'SELECT * FROM vehicle_data', ' WHERE'}
	local parameters = {}

	local restrictions = showroomRestrictions[('%s:%s'):format(data.property, data.zoneId)]
	for k, v in pairs(restrictions) do
		local filter = data.filters[k]
		if k == 'price' or k == 'doors' or k == 'seats' then
			if v.allow then
				query[#query + 1] = (' %s BETWEEN ? AND ?'):format(k)
				parameters[#parameters + 1] = filter?[1] > v.data[1] and filter[1] or v.data[1]
				parameters[#parameters + 1] = filter?[2] < v.data[2] and filter[2] or v.data[2]
			else
				if filter then
					if filter[2] <= v.data[1] or filter[1] >= v.data[2] then
						query[#query + 1] = (' %s BETWEEN ? AND ?'):format(k)
						v.data = filter
					elseif filter[1] < v.data[1] and filter[2] < v.data[2] then
						query[#query + 1] = (' %s BETWEEN ? AND ?'):format(k)
						v.data = {filter[1], v.data[1]}
					elseif filter[1] > v.data[1] and filter[2] > v.data[2] then
						query[#query + 1] = (' %s BETWEEN ? AND ?'):format(k)
						v.data = {v.data[2], filter[2]}
					elseif filter[1] < v.data[1] and filter[2] > v.data[2] then
						query[#query + 1] = (' (%s BETWEEN ? AND ? OR %s BETWEEN ? AND ?)'):format(k, k)
						v.data = {filter[1], v.data[1], v.data[2], filter[2]}
					else
						query[#query + 1] = (' %s NOT BETWEEN ? AND ?'):format(k)
					end

					for i = 1, #v.data do
						parameters[#parameters + 1] = v.data[i]
					end
				else
					query[#query + 1] = (' %s NOT BETWEEN ? AND ?'):format(k)
					parameters[#parameters + 1] = v.data[1]
					parameters[#parameters + 1] = v.data[2]
				end
			end
		elseif type(v.data) == 'table' then
			if v.allow then
				if filter ~= nil then
					if table.contains(v.data, filter) then
						v.data = {filter}
					end
				end

				if #v.data > 1 then
					query[#query + 1] = (' %s IN (?)'):format(k)
					parameters[#parameters + 1] = v.data
				elseif #v.data > 0 then
					query[#query + 1] = (' %s = ?'):format(k)
					parameters[#parameters + 1] = v.data[1]
				end
			else
				local allow
				if filter ~= nil then
					if not table.contains(v.data, filter) then
						v.data = {filter}
						allow = true
					end
				end

				if #v > 1 then
					query[#query + 1] = (' %s NOT IN (?)'):format(k)
					parameters[#parameters + 1] = v.data
				elseif #v.data > 0 then
					if allow then
						query[#query + 1] = (' %s = ?'):format(k)
					else
						query[#query + 1] = (' %s != ?'):format(k)
					end
					parameters[#parameters + 1] = v.data[1]
				end
			end
		elseif (filter == nil or v.data == filter) and not v.allow then
			query[#query + 1] = (' %s != ?'):format(k)
			parameters[#parameters + 1] = v.data
		elseif v.allow then
			query[#query + 1] = (' %s = ?'):format(k)
			parameters[#parameters + 1] = v.data
		else
			query[#query + 1] = (' %s = ?'):format(k)
			parameters[#parameters + 1] = filter
		end

		if #query > 3 then
			query[#query] = ' AND' .. query[#query]
		end
		data.filters[k] = nil
	end

	for k, v in pairs(data.filters) do
		if k == 'model' or k == 'name' then
			query[#query + 1] = (' %s LIKE ?'):format(k)
			parameters[#parameters + 1] = ('%%%s%%'):format(v)
		elseif k == 'price' or k == 'doors' or k == 'seats' then
			query[#query + 1] = (' %s BETWEEN ? AND ?'):format(k)
			parameters[#parameters + 1] = v[1]
			parameters[#parameters + 1] = v[2]
		else
			query[#query + 1] = (' %s = ?'):format(k)
			parameters[#parameters + 1] = v
		end

		if #query > 3 then
			query[#query] = ' AND' .. query[#query]
		end
	end

	if not next(parameters) then
		query[2] = ' ORDER BY name'
	else
		query[#query + 1] = ' ORDER BY name'
	end

	query = table.concat(query)
	return MySQL.query.await(query, parameters)
end)

RegisterServerEvent('ox_vehicledealer:buyWholesale', function(data)
	local player = lib.getPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	-- TODO financial integration
	if true then
		local vehicle = Ox.CreateVehicle(player.charid, {
			model = data.model,
			type = data.type,
		})
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle purchased', type = 'success'})
		Wait(500)
		MySQL.update('UPDATE vehicles SET stored = ? WHERE plate = ?', {('%s:%s'):format(data.property, data.zoneId), vehicle.plate})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:sellWholesale', function(data)
	local player = lib.getPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	-- TODO financial integration
	if true then
		MySQL.update.await('DELETE FROM vehicles WHERE plate = ?', {data.plate})
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle sold', type = 'success'})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:displayVehicle', function(data)
	local player = lib.getPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	local vehicle = MySQL.single.await('SELECT owner, type, data FROM vehicles WHERE plate = ? AND owner = ?', {data.plate, player.charid})

	local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

	if vehicle and spawn and zone.vehicles[vehicle.type] then
		vehicle.data = json.decode(vehicle.data)
		MySQL.update('UPDATE vehicles SET stored = "displayed", x = ?, y = ?, z = ?, heading = ? WHERE plate = ?', {spawn.x, spawn.y, spawn.z, spawn.w, data.plate})

		local veh = Ox.CreateVehicle(vehicle.owner, vehicle.data, spawn)
		veh.modelData = exports.ox_property:getModelData(veh.data.model)
		local vehicles = GlobalState['DisplayedVehicles']
		vehicles[veh.plate] = veh
		GlobalState['DisplayedVehicles'] = vehicles

		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle displayed', type = 'success'})

		Wait(1000)
		FreezeEntityPosition(veh.entity, true)
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to display', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:moveVehicle', function(data)
	local player = lib.getPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	local vehicle = Vehicle(NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(player.source), false)))
	if data.rotate then
		local heading = GetEntityHeading(vehicle.entity) + 180
		SetEntityHeading(vehicle.entity, heading)
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle rotated', type = 'success'})

		MySQL.update('UPDATE vehicles SET heading = ? WHERE plate = ?', {heading, data.plate})
	else
		local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

		if spawn then
			SetEntityCoords(vehicle.entity, spawn.x, spawn.y, spawn.z)
			SetEntityHeading(vehicle.entity, spawn.w)
			TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle moved', type = 'success'})

			MySQL.update('UPDATE vehicles SET x = ?, y = ?, z = ?, heading = ? WHERE plate = ?', {spawn.x, spawn.y, spawn.z, spawn.w, data.plate})
		else
			TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to move', type = 'error'})
		end
	end
end)

RegisterServerEvent('ox_vehicledealer:buyVehicle', function(data)
	local player = lib.getPlayer(source)
	local plyPed = GetPlayerPed(player.source)
	local vehicle = Vehicle(NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(plyPed, false)))
	-- TODO financial integration
	if true then
		MySQL.update.await('UPDATE vehicles SET owner = ?, stored = "false" WHERE plate = ?', {player.charid, vehicle.plate})
		local vehicles = GlobalState['DisplayedVehicles']
		vehicles[vehicle.plate] = nil
		GlobalState['DisplayedVehicles'] = vehicles

		local vehPos = GetEntityCoords(vehicle.entity)
		local vehHeading = GetEntityHeading(vehicle.entity)
		local passengers = {}
		local modelData = exports.ox_property:getModelData(vehicle.data.model)
		for i = -1, modelData.seats - 1 do
			local ped = GetPedInVehicleSeat(vehicle.entity, i)
			if ped ~= 0 then
				passengers[i] = ped
			end
		end

		vehicle.despawn()

		vehicle = Ox.CreateVehicle(player.charid, vehicle.data, vec(vehPos.xyz, vehHeading))
		for k, v in pairs(passengers) do
			SetPedIntoVehicle(v, vehicle.entity, k)
		end

		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle purchased', type = 'success'})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)

AddEventHandler('ox_property:vehicleStateChange', function(plate, action)
	local vehicles = GlobalState['DisplayedVehicles']
	vehicles[plate] = nil
	GlobalState['DisplayedVehicles'] = vehicles
end)
