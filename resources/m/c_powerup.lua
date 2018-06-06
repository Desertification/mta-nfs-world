local powerupRecharging = {}

addEvent("onPowerupStopped", true)
addEvent("onPowerupRecharged", true)

function setPowerupRecharging(powerup, bool)
    powerupRecharging[powerup] = bool
end

function isPowerupRecharging(powerup)
    return powerupRecharging[powerup] == true -- prevents returing nill
end

function onClientKey(key, pressedDown)
    if (key == "num_2" and pressedDown) then
        if (not isPowerupRecharging("juggernaut")) and isPlayerDriving(localPlayer) then
            activatePowerup("juggernaut")
        end
    end
end

function isPlayerDriving(player)
    if (getPedOccupiedVehicle(player)) then
        return getPedOccupiedVehicleSeat(player) == 0
    end
    return false
end

function activatePowerup(powerup)
    setPowerupRecharging(powerup, true)
    triggerServerEvent("onPowerupRequested", resourceRoot, powerup)
    --playSFX("script", 192, 2, false)
    playSound("powerup.wav")
    --temp
    activateJuggernaut(vehicle)
    --temp
end

function stopPowerup(powerup)
    --todo powerdown sound
    --todo visual
    --temp
    stopJuggernaut(vehicle)
    --temp
end

function rechargePowerup(powerup)
    setPowerupRecharging(powerup, false)
    --temp
    removeEventHandler("onClientRender", root, drawJuggernautR)
    --temp
end

function activateJuggernaut(vehicle)
    playSFX("genrl", 32, 55, false)
    addEventHandler("onClientRender", root, drawJuggernaut)
end

function drawJuggernaut()
    local screenWidth,screenHeight = guiGetScreenSize()
    dxDrawImage( screenWidth -50, screenHeight -50, 50, 50, "IconPowerups_Juggernaut.png")
end

function drawJuggernautR()
    local screenWidth,screenHeight = guiGetScreenSize()
    dxDrawImage( screenWidth -50, screenHeight -50, 50, 50, "IconPowerups_Juggernaut_r.png")
end

function stopJuggernaut(vehicle)
    removeEventHandler("onClientRender", root, drawJuggernaut)
    addEventHandler("onClientRender", root, drawJuggernautR)
end

addEventHandler("onClientKey", root, onClientKey)
addEventHandler("onPowerupStopped", root, stopPowerup)
addEventHandler("onPowerupRecharged", root, rechargePowerup)
