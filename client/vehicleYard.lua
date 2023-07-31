exports.ox_property:registerComponentAction('vehicleYard', function(component)
    if cache.seat ~= -1 then
        return lib.notify({title = 'You need to be driving a vehicle', type = 'error'})
    end

    local options = {}
    local permitted = exports.ox_property:isPermitted()

    local displayedVehicle
    local plate = GetVehicleNumberPlateText(cache.vehicle)

    for _, vehicle in pairs(DisplayedVehicles) do
        if vehicle.plate == plate then
            displayedVehicle = vehicle
            break
        end
    end

    if displayedVehicle and displayedVehicle.owner == player.charid and permitted < 2 then
        options['Move Vehicle'] = {
            onSelect = function()
                local response, msg = lib.callback.await('ox_vehicledealer:vehicleYard', 100, 'move_vehicle', {
                    property = component.property,
                    componentId = component.componentId
                })

                if msg then
                    lib.notify({title = msg, type = response and 'success' or 'error'})
                end
            end
        }

        options['Rotate Vehicle'] = {
            onSelect = function()
                local response, msg = lib.callback.await('ox_vehicledealer:vehicleYard', 100, 'move_vehicle', {
                    property = component.property,
                    componentId = component.componentId,
                    rotate = true
                })

                if msg then
                    lib.notify({title = msg, type = response and 'success' or 'error'})
                end
            end
        }

        options['Remove Vehicle From Display'] = {
            onSelect = function()
                SetStatsUi(false)
                local response, msg = lib.callback.await('ox_vehicledealer:vehicleYard', 100, 'retrieve_vehicle', {
                    property = component.property,
                    componentId = component.componentId
                })

                if msg then
                    lib.notify({title = msg, type = response and 'success' or 'error'})
                end
            end
        }
    elseif displayedVehicle then
        options['Buy Vehicle'] = {
            onSelect = function()
                SetStatsUi(false)
                local response, msg = lib.callback.await('ox_vehicledealer:vehicleYard', 100, 'buy_vehicle', {
                    property = component.property,
                    componentId = component.componentId
                })

                if msg then
                    lib.notify({title = msg, type = response and 'success' or 'error'})
                end
            end
        }
    elseif permitted < 2 then
        options['Display Vehicle'] = {
            onSelect = function()
                local data = VehicleData[GetEntityArchetypeName(cache.vehicle)]
                local price = lib.inputDialog(('Set price for %s'):format(data.name), {
                    {type = 'input', label = ('Wholesale price: $%s'):format(data.price), default = data.price},
                })

                if price then
                    local response, msg = lib.callback.await('ox_vehicledealer:vehicleYard', 100, 'display_vehicle', {
                        property = component.property,
                        componentId = component.componentId,
                        price = price[1]
                    })

                    if msg then
                        lib.notify({title = msg, type = response and 'success' or 'error'})
                    end
                end
            end
        }
    end

    return {options = options}, 'contextMenu'
end)
