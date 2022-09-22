local displayedVehicles = {}

AddEventHandler('onServerResourceStart', function(resource)
	if resource ~= cache.resource then return end
	exports.ox_property:loadDataFiles()

	local properties = GlobalState['Properties']
	local vehicles = MySQL.query.await('SELECT id, model, JSON_QUERY(data, "$.display") as display FROM vehicles WHERE stored IS NOT NULL')
	if not vehicles then return end

	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		local display = vehicle.display and json.decode(vehicle.display--[[@as string]] )

		if display then
			local zone = properties[display.property].zones[display.zone]
			local heading = zone.spawns[display.id].w + (display.rotate and 180 or 0)

			local veh = Ox.CreateVehicle(vehicle.id, zone.spawns[display.id].xyz, heading)
			veh.data = Ox.GetVehicleData(vehicle.model)
			displayedVehicles[veh.plate] = veh

			FreezeEntityPosition(veh.entity, true)
		end
	end

	GlobalState['DisplayedVehicles'] = displayedVehicles
end)

RegisterServerEvent('ox_vehicledealer:buyWholesale', function(data)
	local player = Ox.GetPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	-- TODO financial integration
	if true then
		local vehicle = Ox.CreateVehicle({
			model = data.model,
			owner = player.charid,
			properties = {
				color1 = data.color1,
				color2 = data.color2,
				modLivery = data.livery,
				modRoofLivery = data.roofLivery,
			},
		}, GetEntityCoords(player.ped), GetEntityHeading(player.ped))

        for i = 1, 50 do
            Wait(0)
            SetPedIntoVehicle(player.ped, vehicle.entity, -1)

            if GetVehiclePedIsIn(player.ped, false) == vehicle.entity then
                break
            end
        end

		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle purchased', type = 'success'})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:sellWholesale', function(data)
	local player = Ox.GetPlayer(source)
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
	local player = Ox.GetPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	local vehicle = MySQL.single.await('SELECT id, model FROM vehicles WHERE plate = ? AND owner = ?', {data.plate, player.charid})

	if vehicle then
		vehicle.data = Ox.GetVehicleData(vehicle.model)
	end

	local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

	if vehicle and spawn and zone.vehicles[vehicle.data.type] then
		local veh = Ox.CreateVehicle(vehicle.id, spawn.coords, spawn.heading)
		veh.data = vehicle.data

		veh.set('display', {property = data.property, zone = data.zoneId, id = spawn.id, rotate = spawn.rotate})

		displayedVehicles[veh.plate] = veh
		GlobalState['DisplayedVehicles'] = displayedVehicles

		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle displayed', type = 'success'})

		FreezeEntityPosition(veh.entity, true)
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to display', type = 'error'})
	end
end)

RegisterServerEvent('ox_vehicledealer:moveVehicle', function(data)
	local player = Ox.GetPlayer(source)
	local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

	if not exports.ox_property:isPermitted(player, zone) then return end

	local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(GetPlayerPed(player.source), false))
	local display = vehicle.get('display')

	if data.rotate then
		local heading = GetEntityHeading(vehicle.entity) + 180
		SetEntityHeading(vehicle.entity, heading)
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle rotated', type = 'success'})

		vehicle.set('display', {property = display.property, zone = display.zone, id = display.id, rotate = not display.rotate})
	else
		local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

		if spawn then
			SetEntityCoords(vehicle.entity, spawn.coords.x, spawn.coords.y, spawn.coords.z)
			SetEntityHeading(vehicle.entity, spawn.heading)
			TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle moved', type = 'success'})

			vehicle.set('display', {property = display.property, zone = display.zone, id = spawn.id, rotate = spawn.rotate})
		else
			TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to move', type = 'error'})
		end
	end
end)

RegisterServerEvent('ox_vehicledealer:buyVehicle', function(data)
	local player = Ox.GetPlayer(source)
	local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(GetPlayerPed(player.source), false))
	-- TODO financial integration
	if true then
		MySQL.update.await('UPDATE vehicles SET owner = ?, stored = NULL WHERE plate = ?', {player.charid, vehicle.plate})
		local vehicles = GlobalState['DisplayedVehicles']
		vehicles[vehicle.plate] = nil
		GlobalState['DisplayedVehicles'] = vehicles

		local vehPos = GetEntityCoords(vehicle.entity)
		local vehHeading = GetEntityHeading(vehicle.entity)
		local passengers = {}
		local seats = Ox.GetVehicleData(vehicle.model).seats

		for i = -1, seats - 1 do
			local ped = GetPedInVehicleSeat(vehicle.entity, i)
			if ped ~= 0 then
				passengers[i] = ped
			end
		end

		vehicle.despawn()

		vehicle = Ox.CreateVehicle(vehicle.id, vehPos, vehHeading)
		for k, v in pairs(passengers) do
			SetPedIntoVehicle(v, vehicle.entity, k)
		end

		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle purchased', type = 'success'})
	else
		TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
	end
end)

AddEventHandler('ox_property:vehicleStateChange', function(plate, action)
	displayedVehicles[plate] = nil
	GlobalState['DisplayedVehicles'] = displayedVehicles
end)
