local function displayUsedVehicle(source, component, data, vehicle)
    local spawn = lib.callback.await('ox_property:findClearSpawn', source)
    if not spawn then
        return false, 'spawn_not_found'
    end

    local vehicleData = VehicleData[vehicle.model]
    if not component.vehicles[vehicleData.type] then
        return false, 'vehicle_requirements_not_met'
    end

    exports.ox_property:clearVehicleOfPassengers({entity = vehicle.entity, seats = vehicleData.seats})

    ---@diagnostic disable-next-line: missing-parameter
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

    DisplayedVehicles[vehicle.id] = {
        property = component.property,
        component = component.componentId,
        id = vehicle.id,
        owner = vehicle.owner,
        slot = data.slot,
        plate = vehicle.plate,
        model = vehicle.model,
        netid = vehicle.netid,
        price = data.price
    }
    GlobalState['DisplayedVehicles'] = DisplayedVehicles

    Entity(vehicle.entity).state.frozen = true

    return true, 'vehicle_displayed'
end

local function retrieveVehicle(vehicle)
    vehicle.set('display')
    vehicle.setStored()

    DisplayedVehicles[vehicle.id] = nil
    GlobalState['DisplayedVehicles'] = DisplayedVehicles

    Entity(vehicle.entity).state.frozen = false

    return true, 'vehicle_retrieved'
end

local function moveVehicle(source, rotate, vehicle)
    local display = vehicle.get('display')

    if rotate then
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
        local spawn = lib.callback.await('ox_property:findClearSpawn', source)
        if not spawn then
            return false, 'spawn_not_found'
        end

        ---@diagnostic disable-next-line: missing-parameter
        SetEntityCoords(vehicle.entity, spawn.coords.x, spawn.coords.y, spawn.coords.z)
        SetEntityHeading(vehicle.entity, spawn.heading)

        vehicle.set('display', {
            property = display.property,
            component = display.component,
            slot = spawn.id,
            rotate = spawn.rotate,
            price = display.price
        })

        local veh = DisplayedVehicles[vehicle.id]
        veh.slot = spawn.id
        DisplayedVehicles[vehicle.id] = veh
        GlobalState['DisplayedVehicles'] = DisplayedVehicles

        return true, 'vehicle_moved'
    end
end

lib.callback.register('ox_vehicledealer:vehicleYard', function(source, action, data)
    local permitted, msg = exports.ox_property:isPermitted(source, data.property, data.componentId, 'vehicleYard')

    if not permitted or permitted > 2 then
        return false, msg or 'not_permitted'
    end

    local player = Ox.GetPlayer(source) --[[@as OxPlayer]]
    local property = exports.ox_property:getPropertyData(data.property) --[[@as OxPropertyObject]]
    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))

    if not vehicle then
        return false, 'vehicle_not_found'
    end

    if action == 'buy_vehicle' then
        return BuyVehicle(player, property, vehicle)
    end

    if permitted > 1 then
        return false, 'not_permitted'
    elseif vehicle.owner ~= player.charId then
        return false, 'not_vehicle_owner'
    end

    if action == 'retrieve_vehicle' then
        return retrieveVehicle(vehicle)
    elseif action == 'move_vehicle' then
        return moveVehicle(player.source, data.rotate, vehicle)
    end

    local component = property.components[data.componentId]
    if action == 'display_vehicle' then
        return displayUsedVehicle(player.source, component, data, vehicle)
    end

    return false, 'invalid_action'
end)
