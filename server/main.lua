local table = lib.table

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		exports.ox_property:loadDataFiles()

		local displayedVehicles = MySQL.query.await('SELECT charid, data, x, y, z, heading FROM user_vehicles WHERE stored = "displayed"')

		local vehicles = {}
		for i = 1, #displayedVehicles do
			local vehicle = displayedVehicles[i]
			vehicle.data = json.decode(vehicle.data)

			local veh = Ox.CreateVehicle(vehicle.charid, vehicle.data.model, vec(vehicle.x, vehicle.y, vehicle.z, vehicle.heading), vehicle.data)
			veh.modelData = exports.ox_property:getModelData(veh.data.model)
			vehicles[veh.netid] = veh
		end

		GlobalState['DisplayedVehicles'] = vehicles

		Wait(1000)
		for k, v in pairs(vehicles) do
			FreezeEntityPosition(v.entity, true)
		end
	end
end)

lib.callback.register('ox_vehicledealer:getWholesaleVehicles', function(source, data)
	local player = exports.ox_core:getPlayer(source)
	local query = {'SELECT * FROM vehicle_data', ' WHERE'}
	local parameters = {}

	for k, v in pairs(data.filters) do
		if k == 'model' or k == 'name' then
			query[#query + 1] = (' %s LIKE ?'):format(k)
			parameters[#parameters + 1] = ('%%%s%%'):format(v)
		elseif table.contains({'make', 'type', 'bodytype', 'class', 'weapons'}, k) then
			query[#query + 1] = (' %s = ?'):format(k)
			parameters[#parameters + 1] = v
		elseif k == 'price' or k == 'doors' or k == 'seats' then
			query[#query + 1] = (' %s BETWEEN ? AND ?'):format(k)
			parameters[#parameters + 1] = v[1]
			parameters[#parameters + 1] = v[2]
		end
		if #query > 3 then
			query[#query] = ',' .. query[#query]
		end
	end

	if not next(parameters) then
		query[2] = nil
	end

	query = table.concat(query)
	return MySQL.query.await(query, parameters)
end)

RegisterServerEvent('ox_vehicledealer:buyWholesale', function(data)
	local player = exports.ox_core:getPlayer(source)
	-- TODO financial integration
	if true then
		local vehicle = exports.ox_vehicles:generateVehicle(player.charid, {model = joaat(data.model)}, data.type)
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle purchased', type = 'success'})
		Wait(500)
		MySQL.update('UPDATE user_vehicles SET stored = ? WHERE plate = ?', {('%s:%s'):format(data.property, data.zoneId), vehicle.plate})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:sellWholesale', function(data)
	local player = exports.ox_core:getPlayer(source)
	-- TODO financial integration
	if true then
		MySQL.update.await('DELETE FROM user_vehicles WHERE plate = ?', {data.plate})
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle sold', type = 'success'})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:displayVehicle', function(data)
	local player = exports.ox_core:getPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]
	local vehicle = MySQL.single.await('SELECT charid, data FROM user_vehicles WHERE plate = ? AND charid = ?', {data.plate, player.charid})

	local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

	if vehicle and spawn then
		vehicle.data = json.decode(vehicle.data)
		MySQL.update('UPDATE user_vehicles SET stored = "displayed", x = ?, y = ?, z = ?, heading = ? WHERE plate = ?', {spawn.x, spawn.y, spawn.z, spawn.w, vehicle.data.plate})

		local veh = Ox.CreateVehicle(vehicle.charid, vehicle.data.model, spawn, vehicle.data)
		veh.modelData = exports.ox_property:getModelData(veh.data.model)
		local vehicles = GlobalState['DisplayedVehicles']
		vehicles[veh.netid] = veh
		GlobalState['DisplayedVehicles'] = vehicles

		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle displayed', type = 'success'})

		Wait(1000)
		FreezeEntityPosition(veh.entity, true)
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to display', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:moveVehicle', function(data)
	local player = exports.ox_core:getPlayer(source)
	local vehicle = Vehicle(NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(player.source), false)))
	if data.rotate then
		local heading = GetEntityHeading(vehicle.entity) + 180
		SetEntityHeading(vehicle.entity, heading)
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle rotated', type = 'success'})

		MySQL.update('UPDATE user_vehicles SET heading = ? WHERE plate = ?', {heading, data.plate})
	else
		local zone = GlobalState['Properties'][data.property].zones[data.zoneId]
		local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

		if spawn then
			SetEntityCoords(vehicle.entity, spawn.x, spawn.y, spawn.z)
			SetEntityHeading(vehicle.entity, spawn.w)
			TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle moved', type = 'success'})

			MySQL.update('UPDATE user_vehicles SET x = ?, y = ?, z = ?, heading = ? WHERE plate = ?', {spawn.x, spawn.y, spawn.z, spawn.w, data.plate})
		else
			TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to move', type = 'error'})
		end
	end
end)

RegisterServerEvent('ox_vehicledealer:buyVehicle', function(data)
	local player = exports.ox_core:getPlayer(source)
	local plyPed = GetPlayerPed(player.source)
	local vehicle = Vehicle(NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(plyPed, false)))
	-- TODO financial integration
	if true then
		MySQL.update.await('UPDATE user_vehicles SET charid = ?, stored = "false" WHERE plate = ?', {player.charid, vehicle.data.plate})
		local vehicles = GlobalState['DisplayedVehicles']
		vehicles[vehicle.netid] = nil
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

		local vehicle = Ox.CreateVehicle(player.charid, vehicle.data.model, vec(vehPos.xyz, vehHeading), vehicle.data)
		for k, v in pairs(passengers) do
			SetPedIntoVehicle(v, vehicle.entity, k)
		end

		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle purchased', type = 'success'})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)
