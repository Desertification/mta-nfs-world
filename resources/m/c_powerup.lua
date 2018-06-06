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
    playSFX("script", 192, 2, false)
end

function stopPowerup(powerup)
    --todo powerdown sound
    --todo visual
end

function rechargePowerup(powerup)
    setPowerupRecharging(powerup, false)
end

function activateJuggernaut(vehicle)
    playSFX("genrl", 32, 55, false)
end

function endJuggernaut(vehicle)
    
end

addEventHandler("onClientKey", root, onClientKey)
addEventHandler("onPowerupStopped", root, stopPowerup)
addEventHandler("onPowerupRecharged", root, rechargePowerup)
