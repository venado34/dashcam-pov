print("--- LOADING DASHCAM-POV V1.1 (LVC FIX) ---")

local dashcamActive = false
local attachedVehicle = nil
local cameraHandle = nil
local department = "PPRP"
local callsign = "CAM-1"

RegisterKeyMapping(
    DashcamConfig.ToggleCommand,
    'Toggle Dashcam',
    'keyboard',
    'C'
)

RegisterCommand(DashcamConfig.ToggleCommand, function()
    if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
        if dashcamActive then
            DisableDash()
        else
            EnableDash()
        end
    end
end, false)

RegisterCommand('setdash', function(source, args, raw)
    if args[1] then
        department = args[1]
    end
    if args[2] then
        callsign = args[2]
    end

    TriggerEvent('chat:addMessage', {
        color = { 255, 170, 0 },
        multiline = true,
        args = { "[DASHCAM]", string.format("Dashcam info set to Dept: %s | Callsign: %s", department, callsign) }
    })
end, false)

Citizen.CreateThread(function()
    while true do
        if dashcamActive then
            if not IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
                DisableDash()
            end

            UpdateDashcam()
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if dashcamActive then
            local boneIndex = GetEntityBoneIndexByName(attachedVehicle, "windscreen")
            if boneIndex == -1 then
                boneIndex = GetEntityBoneIndexByName(attachedVehicle, "bonnet")
            end

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


function EnableDash()
    SendNUIMessage({ type = "hud", hud = false })

    attachedVehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)

    if DashcamConfig.RestrictVehicles then
        if not CheckVehicleRestriction() then
            SendNUIMessage({ type = "hud", hud = true })
            return
        end
    end

    SetTimecycleModifier("glasses_VISOR")
    SetTimecycleModifierStrength(0.8)

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(1, 0, 0, 1, 1)
    SetFocusEntity(attachedVehicle)
    cameraHandle = cam

    SendNUIMessage({
        type = "enabledash"
    })

    dashcamActive = true
end

function DisableDash()
    SendNUIMessage({ type = "hud", hud = true })

    ClearTimecycleModifier("glasses_VISOR")
    RenderScriptCams(0, 0, 1, 1, 1)

    if cameraHandle ~= nil then
        DestroyCam(cameraHandle, false)
        cameraHandle = nil
    end

    SetFocusEntity(GetPlayerPed(PlayerId()))

    SendNUIMessage({
        type = "disabledash"
    })

    dashcamActive = false
    attachedVehicle = nil
end

function UpdateDashcam()
    local gameTime = GetGameTimer()
    local year, month, day, hour, minute, second = GetLocalTime()
    local unitNumber = GetPlayerServerId(PlayerId())
    local unitName = GetPlayerName(PlayerId())
    local unitSpeed = 0.0
    local lightsOn = false
    local sirenOn = false

    if attachedVehicle and DoesEntityExist(attachedVehicle) then
        if DashcamConfig.useMPH then
            unitSpeed = GetEntitySpeed(attachedVehicle) * 2.23694
        else
            unitSpeed = GetEntitySpeed(attachedVehicle) * 3.6
        end

        local lvc = exports['lvc']

        if lvc and lvc.getLightStatus and lvc.getSirenStatus then
            local playerPed = PlayerPedId()
            local lightStatus = lvc.getLightStatus()
            local sirenStatus = lvc.getSirenStatus(playerPed)


            if lightStatus then
                lightsOn = true
            end

            if sirenStatus then
                sirenOn = true
            end
        end
    end

    SendNUIMessage({
        type = "updatedash",
        info = {
            gameTime = gameTime,
            clockTime = { year = year, month = month, day = day, hour = hour, minute = minute, second = second },
            unitNumber = unitNumber,
            unitName = unitName,
            unitSpeed = unitSpeed,
            useMPH = DashcamConfig.useMPH,
            department = department,
            callsign = callsign,
            lightsOn = lightsOn,
            sirenOn = sirenOn
        }
    })
end

function CheckVehicleRestriction()
    if DashcamConfig.RestrictionType == "custom" then
        local modelHash = GetEntityModel(attachedVehicle)
        for a = 1, #DashcamConfig.AllowedVehicles do
            if GetHashKey(DashcamConfig.AllowedVehicles[a]) == modelHash then
                return true
            end
        end
        return false
    elseif DashcamConfig.RestrictionType == "class" then
        if GetVehicleClass(attachedVehicle) == 18 then
            return true
        else
            return false
        end
    else
        return false
    end
end
