local function displayUsedVehicle(component, data, vehicle)
    local spawn = exports.ox_property:findClearSpawn(component.spawns, data.entities)
    local vehicleData = VehicleData[vehicle.model]
    if not spawn then
        return false, 'spawn_not_found'
    elseif not component.vehicles[vehicleData.type] then
        return false, 'vehicle_requirements_not_met'
    end

    exports.ox_property:clearVehicleOfPassengers({entity = vehicle.entity, seats = vehicleData.seats})


    SetEntityCoords(vehicle.entity, spawn.coords.x, spawn.coords.y, spawn.coords.z)
    SetEntityHeading(vehicle.entity, spawn.heading)

    vehicle.set('display', {
        property = component.property,
        component = component.componentId,
        slot = data.slot,
        rotate = spawn.rotate,
        price = data.price
    })
    vehicle.setStored('displayed')

    DisplayedVehicles[vehicle.plate] = {
        property = component.property,
        component = component.componentId,
        owner = vehicle.owner,
        slot = data.slot,
        plate = vehicle.plate,
        model = vehicle.model,
        netid = vehicle.netid,
        name = vehicle.data.name,
        price = data.price
    }
    GlobalState['DisplayedVehicles'] = DisplayedVehicles

    FreezeEntityPosition(vehicle.entity, true)

    return true, 'vehicle_displayed'
end

local function retrieveVehicle(vehicle)
    vehicle.set('display')
    vehicle.setStored()

    DisplayedVehicles[vehicle.plate] = nil
    GlobalState['DisplayedVehicles'] = DisplayedVehicles

    FreezeEntityPosition(vehicle.entity, false)

    return true, 'vehicle_retrieved'
end

local function moveVehicle(component, data, vehicle)
    local display = vehicle.get('display')

    if data.rotate then
        SetEntityHeading(vehicle.entity, GetEntityHeading(vehicle.entity) + 180)

        vehicle.set('display', {
            property = display.property,
            component = display.component,
            slot = display.id,
            rotate = not display.rotate,
            price = display.price
        })

        return true, 'vehicle_rotated'
    else
        local spawn = exports.ox_property:findClearSpawn(component.spawns, data.entities)
        if not spawn then
            return false, 'spawn_not_found'
        end

        SetEntityCoords(vehicle.entity, spawn.coords.x, spawn.coords.y, spawn.coords.z)
        SetEntityHeading(vehicle.entity, spawn.heading)

        vehicle.set('display', {
            property = display.property,
            component = display.component,
            slot = spawn.id,
            rotate = spawn.rotate,
            price = display.price
        })

        local veh = DisplayedVehicles[vehicle.plate]
        veh.slot = spawn.id
        DisplayedVehicles[vehicle.plate] = veh
        GlobalState['DisplayedVehicles'] = DisplayedVehicles

        return true, 'vehicle_moved'
    end
end

lib.callback.register('ox_vehicledealer:vehicleYard', function(source, action, data)
    local permitted, msg = exports.ox_property:isPermitted(source, data.property, data.componentId, 'vehicleYard')

    if not permitted or permitted > 2 then
        return false, msg or 'not_permitted'
    end

    local player = Ox.GetPlayer(source)
    local property = exports.ox_property:getPropertyData(data.property)
    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))
    if action == 'buy_vehicle' then
        return BuyVehicle(player, property, vehicle)
    end

    if permitted > 1 then
        return false, 'not_permitted'
    elseif not vehicle then
        return false, 'vehicle_not_found'
    elseif vehicle.owner ~= player.charid then
        return false, 'not_vehicle_owner'
    end

    if action == 'retrieve_vehicle' then
        return retrieveVehicle(vehicle)
    end

    local component = property.components[data.componentId]
    if action == 'move_vehicle' then
        return moveVehicle(component, data, vehicle)
    elseif action == 'display_vehicle' then
        return displayUsedVehicle(component, data, vehicle)
    end

    return false, 'invalid_action'
end)
