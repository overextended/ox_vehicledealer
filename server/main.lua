local displayedVehicles = {}

AddEventHandler('onServerResourceStart', function(resource)
    if resource ~= cache.resource then return end
    exports.ox_property:loadDataFiles()

    local properties = GlobalState['Properties']
    local vehicles = MySQL.query.await('SELECT id, model, JSON_QUERY(data, "$.display") as display FROM vehicles WHERE stored = "displayed"')
    if not vehicles then return end

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local display = vehicle.display and json.decode(vehicle.display--[[@as string]] )

        if display then
            local zone = properties[display.property].zones[display.zone]
            local heading = zone.spawns[display.slot].w + (display.rotate and 180 or 0)

            local veh = Ox.CreateVehicle(vehicle.id, zone.spawns[display.slot].xyz, heading)

            veh.setStored('displayed')

            displayedVehicles[veh.plate] = {
                property = display.property,
                zone = display.zone,
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

    GlobalState['DisplayedVehicles'] = displayedVehicles
end)

lib.callback.register('ox_vehicledealer:getDealerVehicles', function(source, data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, true) then return end

    local dealerVehicles = MySQL.query.await('SELECT plate, model FROM vehicles WHERE stored = ? AND owner = ?', {('%s:%s'):format(data.property, data.zoneId), player.charid})

    for k, v in pairs(displayedVehicles) do
        if data.property == v.property and data.zoneId == v.zone then
            v.gallery = true
            dealerVehicles[#dealerVehicles + 1] = v
        end
    end

    return dealerVehicles
end)

lib.callback.register('ox_vehicledealer:getUsedVehicles', function(source, data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, false) then return end

    local vehicles = MySQL.query.await('SELECT plate FROM vehicles WHERE stored = "displayed" AND owner = ?', {player.charid})

    local usedVehicles = {}
    for k, v in pairs(vehicles) do
        local vehicle = displayedVehicles[v.plate]
        if vehicle and data.property == vehicle.property and data.zoneId == vehicle.zone then
            vehicle.data = Ox.GetVehicleData(vehicle.model)
            usedVehicles[vehicle.plate] = vehicle
        end
    end

    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))

    return usedVehicles, vehicle and Ox.GetVehicleData(vehicle.model)
end)

RegisterServerEvent('ox_vehicledealer:buyWholesale', function(data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, true) then return end

    local modelData =  Ox.GetVehicleData(data.model)
    if not modelData or not zone.restrictions.type[modelData.type] or not zone.restrictions.class[modelData.class] or (zone.restrictions.weapons ~= nil and zone.restrictions.weapons ~= modelData.weapons) then
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle not available', type = 'error'})
        return
    end

    if exports.pefcl:getTotalBankBalanceByIdentifier(player.source, player.charid).data >= modelData.price then
        exports.pefcl:removeBankBalanceByIdentifier(player.source, {
            identifier = zone.owner,
            amount = modelData.price,
            message = ('%s Wholesale'):format(modelData.name)
        })

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

    if not exports.ox_property:isPermitted(player, zone, true) then return end

    local vehicle = displayedVehicles[data.plate]
    local veh
    if vehicle then
        veh = Ox.GetVehicle(NetworkGetEntityFromNetworkId(vehicle.netid))
    else
        veh = MySQL.single.await('SELECT model FROM vehicles WHERE plate = ? AND owner = ?', {data.plate, player.charid})
    end

    local modelData = Ox.GetVehicleData(veh.model)

    exports.pefcl:removeBankBalanceByIdentifier(player.source, {
        identifier = player.charid,
        amount = modelData.price,
        message = ('%s Wholesale'):format(modelData.name)
    })

    if vehicle then
        veh.delete()

        displayedVehicles[vehicle.plate] = nil
        GlobalState['DisplayedVehicles'] = displayedVehicles
    else
        MySQL.update.await('DELETE FROM vehicles WHERE plate = ?', {data.plate})
    end

    TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle sold', type = 'success'})
end)

RegisterServerEvent('ox_vehicledealer:displayVehicle', function(data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, true) then return end

    local vehicle = MySQL.single.await('SELECT id, model FROM vehicles WHERE plate = ? AND owner = ?', {data.plate, player.charid})

    if vehicle then
        vehicle.data = Ox.GetVehicleData(vehicle.model)
    end

    local spawn = zone.spawns[data.slot]

    if vehicle and spawn and zone.vehicles[vehicle.data.type] then
        local veh = Ox.CreateVehicle(vehicle.id, spawn.xyz, spawn.w)

        veh.set('display', {property = data.property, zone = data.zoneId, slot = data.slot, rotate = spawn.rotate, price = data.price})
        veh.setStored('displayed')

        displayedVehicles[veh.plate] = {
            property = data.property,
            zone = data.zoneId,
            slot = data.slot,
            plate = veh.plate,
            model = veh.model,
            netid = veh.netid,
            name = vehicle.data.name,
            price = data.price
        }
        GlobalState['DisplayedVehicles'] = displayedVehicles

        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle displayed', type = 'success'})

        FreezeEntityPosition(veh.entity, true)
    else
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to display', type = 'error'})
    end
end)

RegisterServerEvent('ox_vehicledealer:displayUsedVehicle', function(data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, false) then return end

    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))

    if vehicle.owner ~= player.charid then
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Permission Denied', type = 'error'})
        return
    end

    vehicle.data = Ox.GetVehicleData(vehicle.model)

    local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

    if vehicle and spawn and zone.vehicles[vehicle.data.type] then
        exports.ox_property:clearVehicleOfPassengers(vehicle)

        SetEntityCoords(vehicle.entity, spawn.coords.x, spawn.coords.y, spawn.coords.z)
        SetEntityHeading(vehicle.entity, spawn.heading)

        vehicle.set('display', {property = data.property, zone = data.zoneId, slot = data.slot, rotate = spawn.rotate, price = data.price})
        vehicle.setStored('displayed')

        displayedVehicles[vehicle.plate] = {
            property = data.property,
            zone = data.zoneId,
            slot = data.slot,
            plate = vehicle.plate,
            model = vehicle.model,
            netid = vehicle.netid,
            name = vehicle.data.name,
            price = data.price
        }
        GlobalState['DisplayedVehicles'] = displayedVehicles

        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle displayed', type = 'success'})

        FreezeEntityPosition(vehicle.entity, true)
    else
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to display', type = 'error'})
    end
end)

RegisterServerEvent('ox_vehicledealer:retrieveUsedVehicle', function(data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, true) then return end

    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(GetPlayerPed(player.source), false))

    if vehicle.owner ~= player.charid then
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Permission Denied', type = 'error'})
        return
    end

    vehicle.set('display')
    vehicle.setStored()

    displayedVehicles[vehicle.plate] = nil
    GlobalState['DisplayedVehicles'] = displayedVehicles

    FreezeEntityPosition(vehicle.entity, false)
end)

RegisterServerEvent('ox_vehicledealer:moveUsedVehicle', function(data)
    local player = Ox.GetPlayer(source)
    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(GetPlayerPed(player.source), false))

    if vehicle.owner ~= player.charid then
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Permission Denied', type = 'error'})
        return
    end

    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]
    local display = vehicle.get('display')

    if data.rotate then
        local heading = GetEntityHeading(vehicle.entity) + 180
        SetEntityHeading(vehicle.entity, heading)
        vehicle.set('display', {property = display.property, zone = display.zone, id = display.id, rotate = not display.rotate, price = display.price})

        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle rotated', type = 'success'})
    else
        local spawn = exports.ox_property:findClearSpawn(zone.spawns, data.entities)

        if spawn then
            SetEntityCoords(vehicle.entity, spawn.coords.x, spawn.coords.y, spawn.coords.z)
            SetEntityHeading(vehicle.entity, spawn.heading)
            vehicle.set('display', {property = display.property, zone = display.zone, id = spawn.id, rotate = spawn.rotate, price = display.price})

            TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle moved', type = 'success'})
        else
            TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle failed to move', type = 'error'})
        end
    end
end)

RegisterServerEvent('ox_vehicledealer:hideVehicle', function(data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, true) then return end

    local vehicle = Ox.GetVehicle(NetworkGetEntityFromNetworkId(displayedVehicles[data.plate].netid))

    exports.ox_property:clearVehicleOfPassengers(vehicle)

    vehicle.set('display')
    vehicle.setStored(('%s:%s'):format(data.property, data.zoneId), true)

    displayedVehicles[vehicle.plate] = nil
    GlobalState['DisplayedVehicles'] = displayedVehicles
end)

RegisterServerEvent('ox_vehicledealer:buyVehicle', function(data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, false) then return end

    local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(GetPlayerPed(player.source), false))

    local price = displayedVehicles[vehicle.plate].price
    if not price then
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle not displayed', type = 'error'})
        return
    end

    local modelData = Ox.GetVehicleData(vehicle.model)

    if exports.pefcl:getTotalBankBalanceByIdentifier(player.source, player.charid).data >= price then
        local message = ('%s Purchase'):format(modelData.name)

        exports.pefcl:removeBankBalanceByIdentifier(player.source, {
            identifier = player.charid,
            amount = price,
            message = message
        })

        exports.pefcl:addBankBalanceByIdentifier(player.source, {
            identifier = vehicle.owner,
            amount = price,
            message = message
        })

        vehicle.set('display')
        vehicle.setStored()
        vehicle.setOwner(player.charid)

        displayedVehicles[vehicle.plate] = nil
        GlobalState['DisplayedVehicles'] = displayedVehicles

        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle purchased', type = 'success'})

        FreezeEntityPosition(vehicle.entity, false)
    else
        TriggerClientEvent('ox_lib:notify', player.source, {title = 'Vehicle transaction failed', type = 'error'})
    end
end)

RegisterServerEvent('ox_vehicledealer:updatePrice', function(data)
    local player = Ox.GetPlayer(source)
    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]

    if not exports.ox_property:isPermitted(player, zone, true) then return end

    local vehicle = displayedVehicles[data.plate]
    local veh = Ox.GetVehicle(NetworkGetEntityFromNetworkId(vehicle.netid))

    local display = veh.get('display')
    display.price = data.price
    veh.set('display', display)

    vehicle.price = data.price
    displayedVehicles[vehicle.plate] = vehicle
    GlobalState['DisplayedVehicles'] = displayedVehicles
end)

AddEventHandler('ox_property:vehicleStateChange', function(plate, action)
    displayedVehicles[plate] = nil
    GlobalState['DisplayedVehicles'] = displayedVehicles
end)
