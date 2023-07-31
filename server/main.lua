DisplayedVehicles = {}

VehicleData = setmetatable({}, {
	__index = function(self, index)
		local data = Ox.GetVehicleData(index)

		if data then
			data = {
				name = data.name,
				type = data.type,
				seats = data.seats,
				price = data.price,
				class = data.class,
				weapons = data.weapons,
			}

			self[index] = data
			return data
		end
	end
})

AddEventHandler('onServerResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local vehicles = MySQL.query.await('SELECT id, model, JSON_QUERY(data, "$.display") as display FROM vehicles WHERE stored = "displayed"')
    if not vehicles then return end

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local display = vehicle.display and json.decode(vehicle.display--[[@as string]] )

        if display then
            local component = exports.ox_property:getPropertyData(display.property, display.component)
            local heading = component.spawns[display.slot].w + (display.rotate and 180 or 0)

            local veh = Ox.CreateVehicle(vehicle.id, component.spawns[display.slot].xyz, heading)

            if veh then
                veh.setStored('displayed')

                DisplayedVehicles[veh.id] = {
                    property = display.property,
                    component = display.component,
                    id = veh.id,
                    owner = veh.owner,
                    slot = display.slot,
                    plate = veh.plate,
                    model = veh.model,
                    netid = veh.netid,
                    price = display.price
                }

                FreezeEntityPosition(veh.entity, true)
            end
        end
    end

    GlobalState['DisplayedVehicles'] = DisplayedVehicles
end)

function BuyVehicle(player, property, vehicle)
    vehicle = vehicle or Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))
    local displayData = DisplayedVehicles[vehicle.id]

    if not displayData then
        return false, 'vehicle_not_displayed'
    end

    if property.owner ~= player.charid and vehicle.owner ~= player.charid then
        local response, msg = exports.ox_property:transaction(player.source, ('%s Purchase'):format(displayData.name), {
            amount = displayData.price,
            from = {name = player.name, identifier = player.charid},
            to = {name = property.groupName or property.ownerName, identifier = property.group or property.owner}
        })

        if not response then
            return false, msg
        end
    end

    vehicle.set('display')
    vehicle.setStored()
    vehicle.setOwner(player.charid)

    DisplayedVehicles[vehicle.id] = nil
    GlobalState['DisplayedVehicles'] = DisplayedVehicles

    FreezeEntityPosition(vehicle.entity, false)

    return true, 'vehicle_purchased'
end
