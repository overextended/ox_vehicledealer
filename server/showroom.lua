local function export(player, property, data)
    local vehicle = DisplayedVehicles[data.id]
    local veh = vehicle and Ox.GetVehicleFromNetId(vehicle.netid) or MySQL.single.await('SELECT model FROM vehicles WHERE id = ? AND owner = ?', {data.id, player.charid})

    if not veh then
        return false, 'vehicle_not_found'
    end

    local vehicleData = VehicleData[veh.model]

    if not vehicleData then
        return false, 'model_not_found'
    end

    local response, msg = exports.ox_property:transaction(player.source, ('%s Export'):format(vehicleData.name), {
        amount = vehicleData.price,
        to = {name = property.groupName or property.ownerName, identifier = property.group or property.owner}
    })

    if not response then
        return false, msg
    end

    if vehicle then
        veh.delete()

        DisplayedVehicles[vehicle.id] = nil
        GlobalState['DisplayedVehicles'] = DisplayedVehicles
    else
        MySQL.update.await('DELETE FROM vehicles WHERE id = ?', {data.id})
    end

    return MySQL.query.await('SELECT id, model FROM vehicles WHERE stored = ?', {('%s:%s'):format(data.property, data.componentId)}), 'vehicle_sold'
end

local function displayVehicle(player, component, data)
    local vehicle = MySQL.single.await('SELECT id, model FROM vehicles WHERE id = ? AND owner = ?', {data.id, player.charid})
    local spawn = component.spawns[data.slot]

    if not vehicle then
        return false, 'vehicle_not_found'
    elseif not spawn then
        return false, 'spawn_not_found'
    end

    local vehicleType = VehicleData[vehicle.model]?.type

    if not vehicleType then
        return false, 'model_not_found'
    elseif not component.vehicles[vehicleType] then
        return false, 'vehicle_requirements_not_met'
    end

    local veh = Ox.CreateVehicle(vehicle.id, spawn.xyz, spawn.w)

    if not veh then
        return false, 'vehicle_failed_to_create'
    end

    veh.set('display', {
        property = data.property,
        component = data.componentId,
        slot = data.slot,
        rotate = spawn.rotate,
        price = data.price
    })
    veh.setStored('displayed')

    DisplayedVehicles[veh.id] = {
        property = data.property,
        component = data.componentId,
        id = veh.id,
        owner = player.charid,
        slot = data.slot,
        plate = veh.plate,
        model = veh.model,
        netid = veh.netid,
        price = data.price
    }
    GlobalState['DisplayedVehicles'] = DisplayedVehicles

    FreezeEntityPosition(veh.entity, true)

    return true, 'vehicle_displayed'
end

local function hideVehicle(data)
    local vehicle = Ox.GetVehicleFromNetId(DisplayedVehicles[data.id].netid)

    exports.ox_property:clearVehicleOfPassengers({entity = vehicle.entity, model = vehicle.model})

    vehicle.set('display')
    vehicle.setStored(('%s:%s'):format(data.property, data.componentId), true)

    DisplayedVehicles[vehicle.id] = nil
    GlobalState['DisplayedVehicles'] = DisplayedVehicles
end

local function updatePrice(data)
    local vehicle = DisplayedVehicles[data.id]
    local veh = Ox.GetVehicleFromNetId(vehicle.netid)

    local display = veh.get('display')
    display.price = data.price
    veh.set('display', display)

    vehicle.price = data.price
    DisplayedVehicles[vehicle.id] = vehicle
    GlobalState['DisplayedVehicles'] = DisplayedVehicles
end

local function storeVehicle(player, component, properties)
    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))

    if not vehicle then return end

    local response, msg = exports.ox_property:storeVehicle(player.source, component, properties)

    if response then
        DisplayedVehicles[vehicle.id] = nil
        GlobalState['DisplayedVehicles'] = DisplayedVehicles
    end

    return response, msg
end

lib.callback.register('ox_vehicledealer:showroom', function(source, action, data)
    local permitted, msg = exports.ox_property:isPermitted(source, data.property, data.componentId, 'showroom')

    if not permitted or permitted > 2 then
        return false, msg or 'not_permitted'
    end

    local player = Ox.GetPlayer(source)
    local property = exports.ox_property:getPropertyData(data.property)
    if action == 'buy_vehicle' then
        return BuyVehicle(player, property)
    end

    if permitted > 1 then
        return false, msg or 'not_permitted'
    end

    if action == 'get_vehicles' then
        return MySQL.query.await('SELECT id, plate, model FROM vehicles WHERE stored = ?', {('%s:%s'):format(data.property, data.componentId)})
    elseif action == 'update_price' then
        return updatePrice(data)
    elseif action == 'hide_vehicle' then
        return hideVehicle(data), 'vehicle_stored'
    elseif action == 'export' then
        return export(player, property, data)
    end

    local component = property.components[data.componentId]
    if action == 'store_vehicle' then
        return storeVehicle(player, component, data.properties)
    elseif action == 'retrieve_vehicle' then
        return exports.ox_property:retrieveVehicle(player.charid, component, data.id)
    elseif action == 'display_vehicle' then
        return displayVehicle(player, component, data)
    end

    return false, 'invalid_action'
end)
