exports.ox_property:registerComponentAction('import', function(component)
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
    DisplayVehicle.coords = interiorId == 0 and cache.coords or vec3(GetInteriorPosition(interiorId))

    while DisplayVehicle.coords do
        DisableAllControlActions(0)

        if IsDisabledControlPressed(0, 25) then
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end

        Wait(0)
    end
end, 'function')

---@param str string
---@return vector3
local function rgbToVector(str)
    local r, g, b = string.strsplit(',', str:sub(5, -2))
    return vec3(tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0)
end

RegisterNUICallback('changeColor', function(data, cb)
    cb(1)

    if data[1] ~= '' then
        DisplayVehicle.primary = rgbToVector(data[1])
        SetVehicleCustomPrimaryColour(DisplayVehicle.entity, DisplayVehicle.primary.x, DisplayVehicle.primary.y, DisplayVehicle.primary.z)
    end

    if data[2] ~= '' then
        DisplayVehicle.secondary = rgbToVector(data[2])
        SetVehicleCustomSecondaryColour(DisplayVehicle.entity, DisplayVehicle.secondary.x, DisplayVehicle.secondary.y, DisplayVehicle.secondary.z)
    end
end)

RegisterNUICallback('purchaseVehicle', function(data, cb)
    cb(1)
    local component = exports.ox_property:getCurrentComponent()
    local primary, secondary = GetVehicleColours(DisplayVehicle.entity)
    local roofLivery = GetVehicleRoofLivery(DisplayVehicle.entity)

    local response, msg = lib.callback.await('ox_vehicledealer:import', 100, 'import', {
        property = component.property,
        componentId = component.componentId,
        model = data.model,
        color1 = DisplayVehicle.primary and { DisplayVehicle.primary.x, DisplayVehicle.primary.y, DisplayVehicle.primary.z } or primary,
        color2 = DisplayVehicle.secondary and { DisplayVehicle.secondary.x, DisplayVehicle.secondary.y, DisplayVehicle.secondary.z } or secondary,
        livery = DisplayVehicle.livery or -1,
        roofLivery = roofLivery ~= -1 and roofLivery or nil
    })

    if msg then
        lib.notify({title = msg, type = response and 'success' or 'error'})
    end

    CloseUi()
end)

RegisterNUICallback('clickVehicle', function(data, cb)
    cb(1)

    if DisplayVehicle.entity then
        SetModelAsNoLongerNeeded(GetEntityModel(DisplayVehicle.entity))
        SetVehicleAsNoLongerNeeded(DisplayVehicle.entity)
        DeleteEntity(DisplayVehicle.entity)
    end

    local hash = joaat(data.model)

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        repeat Wait(0) until HasModelLoaded(hash)
    end

    local entity = CreateVehicle(hash, DisplayVehicle.coords.x, DisplayVehicle.coords.y, DisplayVehicle.coords.z + 1.0, 90.0, false, false)
	DisplayVehicle.entity = entity

    SetVehicleOnGroundProperly(entity)
    SetPedIntoVehicle(cache.ped, entity, -1)
    FreezeEntityPosition(entity, true)
    SetVehicleDirtLevel(entity, 0.0)
    SetEntityCollision(entity, false, false)

	if GetVehicleLivery(entity) ~= -1 then
		SetVehicleLivery(entity, 0)
		DisplayVehicle.livery = 0
	end
end)
