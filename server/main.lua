local table = lib.table

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		exports.ox_property:loadDataFiles()
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