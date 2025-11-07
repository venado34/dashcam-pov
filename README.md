Sure! Here's the README formatted as a Markdown file (`README.md`):

```markdown
# Dashcam-POV

A fully immersive police dashcam HUD for FiveM, supporting **lights & siren status via LVC**, smooth speed display, local PC time, and auto camera tracking.

---

## Features

- **LVC Integration:** Shows `L` (lights) and `S` (siren) on the HUD.  
- **Local Time:** Uses your PC’s local time in `MM-DD-YYYY - HH:MM:SS` format.  
- **Smooth Speed Display:** Automatically converts vehicle speed to MPH or KMH.  
- **Auto Dashcam:** Turns off when exiting the vehicle.  
- **Custom Department & Callsign:** Can be set via `setdash` command (always uppercase).  
- **Vehicle Restrictions:** Limit dashcam to certain vehicles or vehicle classes.  
- **Realistic HUD:** Follows windscreen/bonnet, visually similar to in-game dashcams.  

---

## Installation

1. Place the `dashcam-pov` folder in your server's `resources` directory.  
2. Add to `server.cfg`:

```

ensure dashcam-pov
ensure lvc

````

3. Open `client.lua` and configure `DashcamConfig`:

```lua
DashcamConfig = {
    ToggleCommand = "toggledash",
    RestrictVehicles = true,
    RestrictionType = "custom", -- "custom" or "class"
    useMPH = true
    
    AllowedVehicles = {
        "police",
        "police2"
    },
}
````

---

## Commands

* **Toggle Dashcam:** Press `C` (default, configurable via `DashcamConfig.ToggleCommand`).
* **Set Department & Callsign:**

```
/setdash [DEPARTMENT] [CALLSIGN]
```

Automatically converts input to **uppercase** for HUD display.

---

## LVC Integration

Dashcam requires LVC to display lights and siren status. Your LVC exports should include:

UTIL/cl_lvc.lua
```lua
-- Lights
exports('getLightStatus', function()
    return lights_on == true or lights_on == 1
end)

-- Siren
exports('getSirenStatus', function(playerPed)
    if not playerPed or not IsPedInAnyVehicle(playerPed, false) then return false end
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local lxsiren_state = state_lxsiren and state_lxsiren[vehicle]
    local pwrcall_state = state_pwrcall and state_pwrcall[vehicle]
    local airmanu_state = state_airmanu and state_airmanu[vehicle]
    return (lxsiren_state and lxsiren_state > 0) or 
           (pwrcall_state and pwrcall_state > 0) or 
           (airmanu_state and airmanu_state > 0) or false
end)
```

---

## NUI HUD

* **Clock:** Top-right corner, local PC time.
* **Department & Callsign:** Below clock, uppercase.
* **Lights (L) and Siren (S):** Light up dynamically.
* **Speed:** MPH or KMH, right-aligned.
* **Property Label & Seal:** Centered text and emblem.

---

## Customization

* Adjust HUD style via `style.css`.
* Change font, color, and position of L/S indicators, clock, speed, and department.
* Enable/disable `DashcamConfig.RestrictVehicles` for vehicle filtering.

---

## Notes

* Works fully with **local PC time**, no server time dependency.
* Auto-updates LVC lights and siren every 500ms.
* Compatible with **FiveM latest versions**.

```

This can be saved directly as `README.md` and will render nicely in GitHub or other Markdown viewers.  

Do you want me to also **add a screenshot section** for the HUD in the README?
```
