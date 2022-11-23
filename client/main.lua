local displayedVehicles = GlobalState['DisplayedVehicles']
local vehicleData = Ox.GetVehicleData()

lib.locale()

local function setStatsUi(data)
    SendNUIMessage({
        action = 'setStatsVisible',
        data = data
    })
end

local displayVehicle = {}

exports.ox_property:registerComponentAction('import/export', function(component)
    if cache.vehicle then
        return lib.notify({title = 'You cannot shop while in a vehicle', type = 'error'})
    end

    local restrictions = exports.ox_property:getPropertyData(component.property, component.componentId).restrictions
    local allowedClasses = {}
    for i = 0, 22 do
        local class = restrictions.class[i]
        if class then
            allowedClasses[#allowedClasses + 1] = i
        end
    end

    SendNUIMessage({
        action = 'setVisible',
        data = {
            visible = true,
            categories = allowedClasses,
            types = restrictions.type,
            weapons = restrictions.weapons
        }
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    NetworkStartSoloTutorialSession()
    SetPlayerInvincible(cache.playerId, true)

    local interiorId = GetInteriorFromEntity(cache.ped)
    cache.coords = GetEntityCoords(cache.ped)
    displayVehicle.coords = interiorId == 0 and cache.coords or vec3(GetInteriorPosition(interiorId))

    while displayVehicle.coords do
        DisableAllControlActions(0)

        if IsDisabledControlPressed(0, 25) then
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end

        Wait(0)
    end
end, 'function')

exports.ox_property:registerComponentAction('showroom', function(component)
    local options = {}
    local subMenus = {}
    local componentVehicles, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'get_vehicles', {
        property = component.property,
        componentId = component.componentId
    })

    if msg then
        lib.notify({title = msg, type = componentVehicles and 'success' or 'error'})
    end
    if not componentVehicles then return end

    local permitted = exports.ox_property:isPermitted()

    if cache.seat == -1 then
        if displayedVehicles[GetVehicleNumberPlateText(cache.vehicle)] then
            options[#options + 1] = {
                title = 'Buy Vehicle',
                onSelect = function()
                    setStatsUi(false)
                    local response, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'buy_vehicle', {
                        property = component.property,
                        componentId = component.componentId
                    })

                    if msg then
                        lib.notify({title = msg, type = response and 'success' or 'error'})
                    end
                end
            }
        elseif permitted < 2 then
            options[#options + 1] = {
                title = 'Store Vehicle',
                onSelect = function()
                    if cache.seat == -1 then
                        local response, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'store_vehicle', {
                            property = component.property,
                            componentId = component.componentId,
                            properties = lib.getVehicleProperties(cache.vehicle)
                        })

                        if msg then
                            lib.notify({title = msg, type = response and 'success' or 'error'})
                        end
                    else
                        lib.notify({title = "You are not in the driver's seat", type = 'error'})
                    end
                end
            }
        end
    end

    if permitted < 2 then
        options[#options + 1] = {
            title = 'Manage Showroom',
            onSelect = function()
                for k, v in pairs(displayedVehicles) do
                    if v.property == component.property and v.component == component.componentId then
                        componentVehicles[#componentVehicles + 1] = {plate = v.plate, model = v.model, gallery = true}
                    end
                end

                SendNUIMessage({
                    action = 'setManagementVisible',
                    data = componentVehicles
                })
                SetNuiFocus(true, true)
            end
        }

        if next(componentVehicles) then
            options[#options + 1] = {
                title = 'Retrieve From Showroom',
                menu = 'stored_vehicles',
                metadata = {['Vehicles'] = #componentVehicles}
            }

            local subOptions = {}
            for i = 1, #componentVehicles do
                local vehicle = componentVehicles[i]
                subOptions[i] = {
                    title = ('%s - %s'):format(vehicleData[vehicle.model].name, vehicle.plate),
                    onSelect = function()
                        local response, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'retrieve_vehicle', {
                            property = component.property,
                            componentId = component.componentId,
                            plate = vehicle.plate,
                            entities = exports.ox_property:getZoneEntities()
                        })

                        if msg then
                            lib.notify({title = msg, type = response and 'success' or 'error'})
                        end
                    end
                }
            end

            subMenus[1] = {
                id = 'stored_vehicles',
                title = 'Retrieve vehicle',
                menu = 'component_menu',
                options = subOptions
            }
        end
    end

    return {options = options, subMenus = subMenus}, 'contextMenu'
end)

exports.ox_property:registerComponentAction('vehicleYard', function(component)
    if cache.seat ~= -1 then
        return lib.notify({title = 'You need to be driving a vehicle', type = 'error'})
    end

    local options = {}
    local permitted = exports.ox_property:isPermitted()
    local displayedVehicle = displayedVehicles[GetVehicleNumberPlateText(cache.vehicle)]

    if displayedVehicle and displayedVehicle.owner == player.charid and permitted < 2 then
        options['Move Vehicle'] = {
            onSelect = function()
                local response, msg = lib.callback.await('ox_vehicledealer:vehicleYard', 100, 'move_vehicle', {
                    property = component.property,
                    componentId = component.componentId,
                    entities = exports.ox_property:getZoneEntities()
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
                setStatsUi(false)
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
                setStatsUi(false)
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
                local data = vehicleData[GetEntityArchetypeName(cache.vehicle)]
                local price = lib.inputDialog(('Set price for %s'):format(data.name), {
                    {type = 'input', label = ('Wholesale price: $%s'):format(data.price), default = data.price},
                })

                if price then
                    local response, msg = lib.callback.await('ox_vehicledealer:vehicleYard', 100, 'display_vehicle', {
                        property = component.property,
                        componentId = component.componentId,
                        price = price[1],
                        entities = exports.ox_property:getZoneEntities()
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

CreateThread(function()
    while true do
        Wait(0)
        local closeDist, closeVehicle = 7.5
        local pedPos = GetEntityCoords(cache.ped)
        for k, v in pairs(displayedVehicles) do
            if NetworkDoesEntityExistWithNetworkId(v.netid) then
                v.vehPos = GetEntityCoords(NetToVeh(v.netid))
                local distance = #(pedPos - v.vehPos)
                if closeDist > distance then
                    closeDist = distance
                    closeVehicle = v
                end
            end
        end

        if closeVehicle then
            BeginTextCommandDisplayHelp('FloatingNotification')
            AddTextEntry('FloatingNotification', ('%s - ~g~$%s'):format(closeVehicle.name, closeVehicle.price))
            EndTextCommandDisplayHelp(2, false, false, -1)
            SetFloatingHelpTextWorldPosition(1, closeVehicle.vehPos.x, closeVehicle.vehPos.y, closeVehicle.vehPos.z + 1)
            SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
        end
    end
end)

AddStateBagChangeHandler('DisplayedVehicles', 'global', function(bagName, key, value, reserved, replicated)
    displayedVehicles = value
end)

lib.onCache('vehicle', function(vehicle)
    if vehicle then
        local veh = displayedVehicles[GetVehicleNumberPlateText(vehicle)]
        if veh then
            setStatsUi({veh.model, veh.price})
        end
    else
        setStatsUi(false)
    end
end)
lib.locale()
-- Changes the locales in UI on locale change
RegisterNetEvent('ox_lib:setLocale', function(locale)
    local resource = GetCurrentResourceName()
    local JSON = LoadResourceFile(resource, ('locales/%s.json'):format(locale)) or LoadResourceFile(resource, ('locales/en.json'):format(locale))
    SendNUIMessage({
        action = 'setLocale',
        data = json.decode(JSON)
    })
end)

-- Loads the locales into UI on startup
RegisterNUICallback('loadLocale', function(_, cb)
    cb(1)
    local resource = GetCurrentResourceName()
    local locale = GetExternalKvpString('ox_lib', 'locale') or 'en'
    local JSON = LoadResourceFile(resource, ('locales/%s.json'):format(locale)) or LoadResourceFile(resource, ('locales/en.json'):format(locale))
    SendNUIMessage({
        action = 'setLocale',
        data = json.decode(JSON)
    })
end)

---@param str string
---@return vector3
local function rgbToVector(str)
    local r, g, b = string.strsplit(',', str:sub(5, -2))
    return vec3(tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0)
end

RegisterNUICallback('changeColor', function(data, cb)
    cb(1)

    if data[1] ~= '' then
        displayVehicle.primary = rgbToVector(data[1])
        SetVehicleCustomPrimaryColour(displayVehicle.entity, displayVehicle.primary.x, displayVehicle.primary.y, displayVehicle.primary.z)
    end

    if data[2] ~= '' then
        displayVehicle.secondary = rgbToVector(data[2])
        SetVehicleCustomSecondaryColour(displayVehicle.entity, displayVehicle.secondary.x, displayVehicle.secondary.y, displayVehicle.secondary.z)
    end
end)

local function closeUi(_, cb)
    if cb then cb(1) end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    if displayVehicle.entity then
        SetModelAsNoLongerNeeded(GetEntityModel(displayVehicle.entity))
        SetVehicleAsNoLongerNeeded(displayVehicle.entity)
        DeleteEntity(displayVehicle.entity)
        SetEntityCoordsNoOffset(cache.ped, cache.coords.x, cache.coords.y, cache.coords.z, true, false, false)
    end

    table.wipe(displayVehicle)
    NetworkEndTutorialSession()
    SetPlayerInvincible(cache.playerId, false)
end

RegisterNUICallback('purchaseVehicle', function(data, cb)
    cb(1)
    local component = exports.ox_property:getCurrentComponent()
    local primary, secondary = GetVehicleColours(displayVehicle.entity)
    local roofLivery = GetVehicleRoofLivery(displayVehicle.entity)

    local response, msg = lib.callback.await('ox_vehicledealer:import/export', 100, 'buy_wholesale', {
        property = component.property,
        componentId = component.componentId,
        model = data.model,
        color1 = displayVehicle.primary and { displayVehicle.primary.x, displayVehicle.primary.y, displayVehicle.primary.z } or primary,
        color2 = displayVehicle.secondary and { displayVehicle.secondary.x, displayVehicle.secondary.y, displayVehicle.secondary.z } or secondary,
        livery = displayVehicle.livery or -1,
        roofLivery = roofLivery ~= -1 and roofLivery or nil
    })

    if msg then
        lib.notify({title = msg, type = response and 'success' or 'error'})
    end

    closeUi()
end)

RegisterNUICallback('clickVehicle', function(data, cb)
    cb(1)

    if displayVehicle.entity then
        SetModelAsNoLongerNeeded(GetEntityModel(displayVehicle.entity))
        SetVehicleAsNoLongerNeeded(displayVehicle.entity)
        DeleteEntity(displayVehicle.entity)
    end

    local hash = joaat(data.model)

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        repeat Wait(0) until HasModelLoaded(hash)
    end

    local entity = CreateVehicle(hash, displayVehicle.coords.x, displayVehicle.coords.y, displayVehicle.coords.z + 1.0, 90.0, false, false)
	displayVehicle.entity = entity

    SetVehicleOnGroundProperly(entity)
    SetPedIntoVehicle(cache.ped, entity, -1)
    FreezeEntityPosition(entity, true)
    SetVehicleDirtLevel(entity, 0.0)
    SetEntityCollision(entity, false, false)

	if GetVehicleLivery(entity) ~= -1 then
		SetVehicleLivery(entity, 0)
		displayVehicle.livery = 0
	end
end)

RegisterNUICallback('changeVehicleStockPrice', function(data, cb)
    cb(1)

    local component = exports.ox_property:getCurrentComponent()
    local response, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'update_price', {
        property = component.property,
        componentId = component.componentId,
        price = data.price
    })

    if msg then
        lib.notify({title = msg, type = response and 'success' or 'error'})
    end
end)

RegisterNUICallback('fetchGallery', function(_, cb)
    local component = exports.ox_property:getPropertyData()
    local vehicles = {}

    for k, v in pairs(displayedVehicles) do
        if component.property == v.property and component.componentId == v.component then
            vehicles[v.slot] = k
        end
    end

    for i = 1, #component.spawns do
        if not vehicles[i] then
            vehicles[i] = 0
        end
    end

    cb(vehicles)
end)

RegisterNUICallback('galleryAddVehicle', function(data, cb)
    cb(1)

    local component = exports.ox_property:getCurrentComponent()
    local response, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'display_vehicle', {
        property = component.property,
        componentId = component.componentId,
        plate = data.vehicle,
        price = data.price,
        slot = data.slot
    })

    if msg then
        lib.notify({title = msg, type = response and 'success' or 'error'})
    end
end)

RegisterNUICallback('galleryRemoveVehicle', function(data, cb)
    cb(1)

    local component = exports.ox_property:getCurrentComponent()
    local response, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'hide_vehicle', {
        property = component.property,
        componentId = component.componentId,
        plate = data.vehicle
    })

    if msg then
        lib.notify({title = msg, type = response and 'success' or 'error'})
    end
end)

RegisterNUICallback('sellVehicle', function(plate, cb)
    cb(1)

    local component = exports.ox_property:getCurrentComponent()
    local dealerVehicles, msg = lib.callback.await('ox_vehicledealer:showroom', 100, 'hide_vehicle', {
        property = component.property,
        componentId = component.componentId,
        plate = plate
    })

    if msg then
        lib.notify({title = msg, type = dealerVehicles and 'success' or 'error'})
    end
    if not dealerVehicles then return end

    SendNUIMessage({
        action = 'setManagementVisible',
        data = dealerVehicles
    })
end)

RegisterNUICallback('exit', closeUi)
