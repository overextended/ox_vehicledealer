local function import(player, property, restrictions, data)
    local vehicleData =  VehicleData[data.model]
    if not vehicleData then
        return false, 'model_not_found'
    elseif not restrictions.type[vehicleData.type] or not restrictions.class[vehicleData.class] or (restrictions.weapons ~= nil and restrictions.weapons ~= vehicleData.weapons) then
        return false, 'vehicle_not_available'
    end

    if property.owner ~= player.charid then
        local response, msg = exports.ox_property:transaction(player.source, ('%s Import'):format(vehicleData.name), {
            amount = vehicleData.price,
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
