local displayedVehicles = {}

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

                displayedVehicles[veh.plate] = {
                    property = display.property,
                    component = display.component,
                    owner = veh.owner,
                    slot = display.slot,
                    plate = veh.plate,
                    model = veh.model,
                    netid = veh.netid,
                    name = Ox.GetVehicleData(veh.model).name,
                    price = display.price
                }

                FreezeEntityPosition(veh.entity, true)
            end
        end
    end

    GlobalState['DisplayedVehicles'] = displayedVehicles
end)

local function import(player, property, restrictions, data)
    local modelData =  Ox.GetVehicleData(data.model)
    if not modelData then
        return false, 'model_not_found'
    elseif not restrictions.type[modelData.type] or not restrictions.class[modelData.class] or (restrictions.weapons ~= nil and restrictions.weapons ~= modelData.weapons) then
        return false, 'vehicle_not_available'
    end

    if property.owner ~= player.charid then
        local response, msg = exports.ox_property:transaction(player.source, ('%s Import'):format(modelData.name), {
            amount = modelData.price,
            from = {name = player.name, identifier = player.charid},
            to = {name = property.groupName or property.ownerName, identifier = property.group or property.owner}
        })

        if not response then
            return false, msg
        end
    end

    local vehicle = Ox.CreateVehicle({
        model = data.model,
        owner = player.charid,
        properties = {
            color1 = data.color1,
            color2 = data.color2,
            modLivery = data.livery,
            modRoofLivery = data.roofLivery,
            dirtLevel = 0.0
        },
    }, GetEntityCoords(player.ped), GetEntityHeading(player.ped))

    if not vehicle then
        return false, 'vehicle_failed_to_create'
    end

    for i = 1, 50 do
        Wait(0)
        SetPedIntoVehicle(player.ped, vehicle.entity, -1)

        if GetVehiclePedIsIn(player.ped, false) == vehicle.entity then
            break
        end
    end

    return true, 'vehicle_purchased'
end

lib.callback.register('ox_vehicledealer:import', function(source, action, data)
    local permitted, msg = exports.ox_property:isPermitted(source, data.property, data.componentId, 'import')

    if not permitted or permitted > 1 then
        return false, msg or 'not_permitted'
    end

    local player = Ox.GetPlayer(source)
    local property = exports.ox_property:getPropertyData(data.property)
    local component = property.components[data.componentId]
    if action == 'import' then
        return import(player, property, component.restrictions, data)
    end

    return false, 'invalid_action'
end)

local function export(player, property, component, plate)
    local vehicle = displayedVehicles[plate]
    local veh = vehicle and Ox.GetVehicle(NetworkGetEntityFromNetworkId(vehicle.netid)) or MySQL.single.await('SELECT model FROM vehicles WHERE plate = ? AND owner = ?', {plate, player.charid})

    if not veh then
        return false, 'vehicle_not_found'
    end

    local modelData = Ox.GetVehicleData(veh.model)

    if not modelData then
        return false, 'model_not_found'
    end

    local response, msg = exports.ox_property:transaction(player.source, ('%s Export'):format(modelData.name), {
        amount = modelData.price,
        to = {name = property.groupName or property.ownerName, identifier = property.group or property.owner}
    })

    if not response then
        return false, msg
    end

    if vehicle then
        veh.delete()

        displayedVehicles[vehicle.plate] = nil
        GlobalState['DisplayedVehicles'] = displayedVehicles
    else
        MySQL.update.await('DELETE FROM vehicles WHERE plate = ?', {plate})
    end

    return MySQL.query.await('SELECT plate, model FROM vehicles WHERE stored = ?', {('%s:%s'):format(component.property, component.componentId)}), 'vehicle_sold'
end

local function displayVehicle(player, component, data)
    local vehicle = MySQL.single.await('SELECT id, model FROM vehicles WHERE plate = ? AND owner = ?', {data.plate, player.charid})
    local spawn = component.spawns[data.slot]

    if not vehicle then
        return false, 'vehicle_not_found'
    elseif not spawn then
        return false, 'spawn_not_found'
    end

    vehicle.data = Ox.GetVehicleData(vehicle.model)

    if not component.vehicles[vehicle.data.type] then
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

    displayedVehicles[veh.plate] = {
        property = data.property,
        component = data.componentId,
        owner = player.charid,
        slot = data.slot,
        plate = veh.plate,
        model = veh.model,
        netid = veh.netid,
        name = vehicle.data.name,
        price = data.price
    }
    GlobalState['DisplayedVehicles'] = displayedVehicles

    FreezeEntityPosition(veh.entity, true)

    return true, 'vehicle_displayed'
end

local function hideVehicle(plate)
    local vehicle = Ox.GetVehicle(NetworkGetEntityFromNetworkId(displayedVehicles[plate].netid))

    exports.ox_property:clearVehicleOfPassengers({entity = vehicle.entity, model = vehicle.model})

    vehicle.set('display')
    vehicle.setStored(('%s:%s'):format(data.property, data.componentId), true)

    displayedVehicles[vehicle.plate] = nil
    GlobalState['DisplayedVehicles'] = displayedVehicles
end

local function buyVehicle(player, property, vehicle)
    vehicle = vehicle or Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))
    local displayData = displayedVehicles[vehicle.plate]

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

    displayedVehicles[vehicle.plate] = nil
    GlobalState['DisplayedVehicles'] = displayedVehicles

    FreezeEntityPosition(vehicle.entity, false)

    return true, 'vehicle_purchased'
end

local function updatePrice(data)
    local vehicle = displayedVehicles[data.plate]
    local veh = Ox.GetVehicle(NetworkGetEntityFromNetworkId(vehicle.netid))

    local display = veh.get('display')
    display.price = data.price
    veh.set('display', display)

    vehicle.price = data.price
    displayedVehicles[vehicle.plate] = vehicle
    GlobalState['DisplayedVehicles'] = displayedVehicles
end

lib.callback.register('ox_vehicledealer:showroom', function(source, action, data)
    local permitted, msg = exports.ox_property:isPermitted(source, data.property, data.componentId, 'showroom')

    if not permitted or permitted > 2 then
        return false, msg or 'not_permitted'
    end

    local player = Ox.GetPlayer(source)
    local property = exports.ox_property:getPropertyData(data.property)
    if action == 'buy_vehicle' then
        return buyVehicle(player, property)
    end

    if permitted > 1 then
        return false, msg or 'not_permitted'
    end

    if action == 'get_vehicles' then
        return MySQL.query.await('SELECT plate, model FROM vehicles WHERE stored = ?', {('%s:%s'):format(data.property, data.componentId)})
    elseif action == 'update_price' then
        return updatePrice(data)
    elseif action == 'hide_vehicle' then
        return hideVehicle(data.plate)
    elseif action == 'export' then
        return export(player, property, data.plate)
    end

    local component = property.components[data.componentId]
    if action == 'store_vehicle' then
        return exports.ox_property:storeVehicle(player.source, component, data)
    elseif action == 'retrieve_vehicle' then
        return exports.ox_property:retrieveVehicle(player.charid, component, data)
    elseif action == 'display_vehicle' then
        return displayVehicle(player, component, data)
    end

    return false, 'invalid_action'
end)

local function displayUsedVehicle(component, data, vehicle)
    local spawn = exports.ox_property:findClearSpawn(component.spawns, data.entities)
    vehicle.data = Ox.GetVehicleData(vehicle.model)
    if not spawn then
        return false, 'spawn_not_found'
    elseif not component.vehicles[vehicle.data.type] then
        return false, 'vehicle_requirements_not_met'
    end

    exports.ox_property:clearVehicleOfPassengers({entity = vehicle.entity, seats = vehicle.data.seats})


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

    displayedVehicles[vehicle.plate] = {
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
    GlobalState['DisplayedVehicles'] = displayedVehicles

    FreezeEntityPosition(vehicle.entity, true)

    return true, 'vehicle_displayed'
end

local function retrieveVehicle(vehicle)
    vehicle.set('display')
    vehicle.setStored()

    displayedVehicles[vehicle.plate] = nil
    GlobalState['DisplayedVehicles'] = displayedVehicles

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
            id = display.id,
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
            id = spawn.id,
            rotate = spawn.rotate,
            price = display.price
        })

        local veh = displayedVehicles[vehicle.plate]
        veh.slot = spawn.id
        displayedVehicles[vehicle.plate] = veh
        GlobalState['DisplayedVehicles'] = displayedVehicles

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
        return buyVehicle(player, property, vehicle)
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
