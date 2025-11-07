local dashcamActive = false
local attachedVehicle = nil
local cameraHandle = nil
local department = "PPRP"
local callsign = "CAM-1"

-- Toggle dashcam key
RegisterKeyMapping(DashcamConfig.ToggleCommand, 'Toggle Dashcam', 'keyboard', 'C')
RegisterCommand(DashcamConfig.ToggleCommand, function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        if dashcamActive then DisableDash() else EnableDash() end
    end
end, false)

-- Set department/callsign
RegisterCommand('setdash', function(_, args)
    if args[1] then department = string.upper(args[1]) end
    if args[2] then callsign = string.upper(args[2]) end
    TriggerEvent('chat:addMessage', {
        color = { 255, 170, 0 },
        multiline = true,
        args = { "[DASHCAM]", string.format("Dashcam info set to Dept: %s | Callsign: %s", department, callsign) }
    })
end, false)

-- Enable dashcam
function EnableDash()
    SendNUIMessage({ type = "hud", hud = false })
    attachedVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if DashcamConfig.RestrictVehicles and not CheckVehicleRestriction() then
        SendNUIMessage({ type = "hud", hud = true })
        return
    end
    SetTimecycleModifier("glasses_VISOR")
    SetTimecycleModifierStrength(0.8)
    cameraHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(1, 0, 0, 1, 1)
    SetFocusEntity(attachedVehicle)
    SendNUIMessage({ type = "enabledash" })
    dashcamActive = true
end

-- Disable dashcam
function DisableDash()
    SendNUIMessage({ type = "hud", hud = true })
    ClearTimecycleModifier("glasses_VISOR")
    RenderScriptCams(0, 0, 1, 1, 1)
    if cameraHandle then
        DestroyCam(cameraHandle, false); cameraHandle = nil
    end
    SetFocusEntity(GetPlayerPed(PlayerId()))
    SendNUIMessage({ type = "disabledash" })
    dashcamActive = false
    attachedVehicle = nil
end

-- Camera attachment thread
Citizen.CreateThread(function()
    while true do
        if dashcamActive and attachedVehicle and DoesEntityExist(attachedVehicle) then
            local boneIndex = GetEntityBoneIndexByName(attachedVehicle, "windscreen")
            if boneIndex == -1 then boneIndex = GetEntityBoneIndexByName(attachedVehicle, "bonnet") end
            local bonPos = GetWorldPositionOfEntityBone(attachedVehicle, boneIndex)
            local vehRot = GetEntityRotation(attachedVehicle, 0)
            SetCamCoord(cameraHandle, bonPos.x, bonPos.y, bonPos.z)
            SetCamRot(cameraHandle, vehRot.x, vehRot.y, vehRot.z, 0)
        else
            Citizen.Wait(500)
        end
        Citizen.Wait(0)
    end
end)

-- Dashcam update loop
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()

        -- Auto-disable dashcam if ped exits vehicle
        if dashcamActive and not IsPedInAnyVehicle(ped, false) then
            DisableDash()
        end

        if dashcamActive and attachedVehicle and DoesEntityExist(attachedVehicle) then
            local unitSpeed = DashcamConfig.useMPH and GetEntitySpeed(attachedVehicle) * 2.23694 or
            GetEntitySpeed(attachedVehicle) * 3.6

            -- LVC lights & siren
            local lightsOn, sirenOn = false, false
            local lvc = exports['lvc']

            if lvc then
                if type(lvc.getLightStatus) == "function" then
                    lightsOn = lvc.getLightStatus() == true
                end
                if type(lvc.getSirenStatus) == "function" then
                    if ped and IsPedInAnyVehicle(ped, false) then
                        sirenOn = lvc.getSirenStatus(ped) == true
                    end
                end
            end

            -- Send info to NUI
            SendNUIMessage({
                type = "updatedash",
                info = {
                    unitSpeed = unitSpeed,
                    useMPH = DashcamConfig.useMPH,
                    department = department,
                    callsign = callsign,
                    lightsOn = lightsOn,
                    sirenOn = sirenOn
                }
            })
        end
        Citizen.Wait(500)
    end
end)

-- Vehicle restriction check
function CheckVehicleRestriction()
    if DashcamConfig.RestrictionType == "custom" then
        local modelHash = GetEntityModel(attachedVehicle)
        for _, v in ipairs(DashcamConfig.AllowedVehicles) do
            if GetHashKey(v) == modelHash then return true end
        end
        return false
    elseif DashcamConfig.RestrictionType == "class" then
        return GetVehicleClass(attachedVehicle) == 18
    else
        return false
    end
end
