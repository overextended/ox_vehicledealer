
local table = lib.table
local displayedVehicles = GlobalState['DisplayedVehicles']

lib.locale()

local function setStatsUi(data)
    SendNUIMessage({
        action = 'setStatsVisible',
        data = data
    })
end

exports.ox_property:registerZoneMenu('showroom',
    function(currentZone)
        local options = {}
        local subMenus = {}
        local _, zoneVehicles, vehicleData = lib.callback.await('ox_property:getVehicleList', 100, {
            property = currentZone.property,
            zoneId = currentZone.zoneId,
            propertyOnly = true
        })

        if cache.seat == -1 then
            if displayedVehicles[GetVehicleNumberPlateText(cache.vehicle)] then
                options[#options + 1] = {
                    title = 'Buy Vehicle',
                    event = 'ox_vehicledealer:buyVehicle',
                    args = {
                        property = currentZone.property,
                        zoneId = currentZone.zoneId
                    }
                }
            else
                options[#options + 1] = {
                    title = 'Store Vehicle',
                    event = 'ox_property:storeVehicle',
                    args = {
                        property = currentZone.property,
                        zoneId = currentZone.zoneId
                    }
                }
            end
        end

        options[#options + 1] = {
            title = 'Manage Showroom',
            onSelect = function()
                local dealerVehicles = lib.callback.await('ox_vehicledealer:getDealerVehicles', 100, {
                    property = currentZone.property,
                    zoneId = currentZone.zoneId
                })

                SendNUIMessage({
                    action = 'setManagementVisible',
                    data = dealerVehicles
                })
                SetNuiFocus(true, true)
            end
        }

        if next(zoneVehicles) then
            options[#options + 1] = {
                title = 'Retrieve From Showroom',
                menu = 'stored_vehicles',
                metadata = {['Vehicles'] = #zoneVehicles}
            }

            local subOptions = {}
            for i = 1, #zoneVehicles do
                local vehicle = zoneVehicles[i]
                    subOptions[i] = {
                    title = ('%s - %s'):format(vehicleData[vehicle.model].name, vehicle.plate),
                    event = 'ox_property:retrieveVehicle',
                    args = {
                        property = currentZone.property,
                        zoneId = currentZone.zoneId,
                        plate = vehicle.plate
                    }
                }
            end

            subMenus[1] = {
                id = 'stored_vehicles',
                title = 'Retrieve vehicle',
                menu = 'zone_menu',
                options = subOptions
            }
        end

        return {options = options, subMenus = subMenus}, 'context'
    end
)

exports.ox_property:registerZoneMenu('import/export',
    function(currentZone)
        if cache.vehicle then
            return {
                event = 'ox_lib:notify',
                args = {
                    title = 'You cannot shop while in a vehicle',
                    type = 'error'
                }
            }
        else
            return {
                event = 'ox_vehicledealer:buyWholesale',
                args = {
                    property = currentZone.property,
                    zoneId = currentZone.zoneId
                }
            }
        end
    end
)

exports.ox_property:registerZoneMenu('vehicleYard',
    function(currentZone)
        local options = {}
        local usedVehicles, currentVehicleData = lib.callback.await('ox_vehicledealer:getUsedVehicles', 100, {
            property = currentZone.property,
            zoneId = currentZone.zoneId
        })

        if cache.seat == -1 then
            local plate = GetVehicleNumberPlateText(cache.vehicle)
            if usedVehicles[plate] then
                options['Move Vehicle'] = {
                    serverEvent = 'ox_vehicledealer:moveUsedVehicle',
                    args = {
                        property = currentZone.property,
                        zoneId = currentZone.zoneId,
                        entities = exports.ox_property:getZoneEntities()
                    }
                }

                options['Rotate Vehicle'] = {
                    serverEvent = 'ox_vehicledealer:moveUsedVehicle',
                    args = {
                        property = currentZone.property,
                        zoneId = currentZone.zoneId,
                        rotate = true
                    }
                }

                options['Remove Vehicle From Display'] = {
                    onSelect = function()
                        setStatsUi(false)
                        TriggerServerEvent('ox_vehicledealer:retrieveUsedVehicle', {
                            property = currentZone.property,
                            zoneId = currentZone.zoneId
                        })
                    end
                }
            elseif displayedVehicles[plate] then
                options['Buy Vehicle'] = {
                    onSelect = function()
                        setStatsUi(false)
                        TriggerServerEvent('ox_vehicledealer:buyUsedVehicle', {
                            property = currentZone.property,
                            zoneId = currentZone.zoneId
                        })
                    end
                }
            else
                options['Display Vehicle'] = {
                    onSelect = function()
                        local price = lib.inputDialog(('Set price for %s'):format(currentVehicleData.name), {
                            { type = 'input', label = ('Wholesale price: $%s'):format(currentVehicleData.price), default = currentVehicleData.price },
                        })

                        if price then
                            TriggerServerEvent('ox_vehicledealer:displayUsedVehicle',{
                                property = currentZone.property,
                                zoneId = currentZone.zoneId,
                                price = price[1],
                                entities = exports.ox_property:getZoneEntities()
                            })
                        end
                    end
                }
            end

            return {options = options}, 'context'
        else
            return {
                event = 'ox_lib:notify',
                args = {
                    title = 'You need to be driving a vehicle',
                    type = 'error'
                }
            }
        end
    end
)

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

local displayVehicle = {}

RegisterNetEvent('ox_vehicledealer:buyWholesale', function(data)
    if not exports.ox_property:checkCurrentZone(data) then return end

    local zone = GlobalState['Properties'][data.property].zones[data.zoneId]
    local allowedClasses = {}

    for i = 0, 22 do
        local class = zone.restrictions.class[i]
        if class then
            allowedClasses[#allowedClasses + 1] = i
        end
    end

    SendNUIMessage({
        action = 'setVisible',
        data = {
            visible = true,
            categories = allowedClasses,
            types = zone.restrictions.type,
            weapons = zone.restrictions.weapons
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
end)

RegisterNetEvent('ox_vehicledealer:moveVehicle', function(data)
    if not exports.ox_property:checkCurrentZone(data) then return end

    if not data.rotate then
        data.entities = exports.ox_property:getZoneEntities()
    end
    TriggerServerEvent('ox_vehicledealer:moveVehicle', data)
end)

RegisterNetEvent('ox_vehicledealer:buyVehicle', function(data)
    if not exports.ox_property:checkCurrentZone(data) then return end

    setStatsUi(false)
    TriggerServerEvent('ox_vehicledealer:buyVehicle', data)
end)

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
    local currentZone = exports.ox_property:getCurrentZone()
    local primary, secondary = GetVehicleColours(displayVehicle.entity)
    local roofLivery = GetVehicleRoofLivery(displayVehicle.entity)

    TriggerServerEvent('ox_vehicledealer:buyWholesale', {
        property = currentZone.property,
        zoneId = currentZone.zoneId,
        model = data.model,
        color1 = displayVehicle.primary and { displayVehicle.primary.x, displayVehicle.primary.y, displayVehicle.primary.z } or primary,
        color2 = displayVehicle.secondary and { displayVehicle.secondary.x, displayVehicle.secondary.y, displayVehicle.secondary.z } or secondary,
        livery = displayVehicle.livery or -1,
        roofLivery = roofLivery ~= -1 and roofLivery or nil
    })

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

    local currentZone = exports.ox_property:getCurrentZone()
    data.property = currentZone.property
    data.zoneId = currentZone.zoneId
    TriggerServerEvent('ox_vehicledealer:updatePrice', data)
end)

RegisterNUICallback('fetchGallery', function(_, cb)
    local currentZone = exports.ox_property:getCurrentZone()
    local zone = GlobalState['Properties'][currentZone.property].zones[currentZone.zoneId]
    local vehicles = {}

    for k, v in pairs(displayedVehicles) do
        if currentZone.property == v.property and currentZone.zoneId == v.zone then
            vehicles[v.slot] = k
        end
    end

    for i = 1, #zone.spawns do
        if not vehicles[i] then
            vehicles[i] = 0
        end
    end

    cb(vehicles)
end)

RegisterNUICallback('galleryAddVehicle', function(data, cb)
    cb(1)

    local currentZone = exports.ox_property:getCurrentZone()
    TriggerServerEvent('ox_vehicledealer:displayVehicle', {
        property = currentZone.property,
        zoneId = currentZone.zoneId,
        plate = data.vehicle,
        price = data.price,
        slot = data.slot
    })
end)

RegisterNUICallback('galleryRemoveVehicle', function(data, cb)
    cb(1)

    local currentZone = exports.ox_property:getCurrentZone()
    TriggerServerEvent('ox_vehicledealer:hideVehicle', {
        property = currentZone.property,
        zoneId = currentZone.zoneId,
        plate = data.vehicle
    })
end)

RegisterNUICallback('sellVehicle', function(plate, cb)
    cb(1)

    local currentZone = exports.ox_property:getCurrentZone()
    TriggerServerEvent('ox_vehicledealer:sellWholesale', {
        property = currentZone.property,
        zoneId = currentZone.zoneId,
        plate = plate
    })
end)

RegisterNUICallback('exit', closeUi)
