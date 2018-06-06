local juggernaut = {
    mass = 4,
    acceleration = 1.5,
    collision = 0,
    com = -10
}

local powerupDuration = {
    ["juggernaut"] = 5000
}

local powerupCooldown = {
    ["juggernaut"] = 20000
}

local powerupRecharging = {}

addEvent("onPowerupRequested", true)

function handlePowerupRequest(powerup)
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle and not isPowerupRecharging(vehicle, powerup) then
        activatePowerup(client, vehicle, powerup)
    end
end

function isPowerupRecharging(vehicle, powerup)
    if powerupRecharging[vehicle] then
        return powerupRecharging[vehicle][powerup] == true
    end
    return false
end

function setPowerupRecharging(vehicle, powerup, bool)
    if not powerupRecharging[vehicle] then
        powerupRecharging[vehicle] = {}
    end
    powerupRecharging[vehicle][powerup] = bool
end

function activatePowerup(player, vehicle, powerup)
    setPowerupRecharging(vehicle, powerup, true)
    setTimer(stopPowerup, powerupDuration[powerup], 1, player, vehicle, powerup)
    --temp
    activateJuggernaut(vehicle)
    --temp
end

function stopPowerup(player, vehicle, powerup)
    triggerClientEvent(player, "onPowerupStopped", player, powerup)
    setTimer(rechargePowerup, powerupDuration[powerup], 1, player, vehicle, powerup)
    --temp
    stopJuggernaut(vehicle)
    --temp
end

function rechargePowerup(player, vehicle, powerup)
    setPowerupRecharging(vehicle, powerup, false)
    triggerClientEvent(player, "onPowerupRecharged", player, powerup)
end

function resetVehicleHandling(vehicle, property)
    setVehicleHandling(vehicle, property, nil, false)
end

function activateJuggernaut(vehicle)
    local vehicleHandling = getVehicleHandling(vehicle)
    setVehicleHandling(vehicle, "mass", vehicleHandling["mass"] * juggernaut.mass)
    setVehicleHandling(vehicle, "engineAcceleration", vehicleHandling["engineAcceleration"] * juggernaut.acceleration)
    setVehicleHandling(vehicle, "collisionDamageMultiplier", juggernaut.collision)
    setVehicleHandling(vehicle, "centerOfMass", juggernaut.com)
end

function stopJuggernaut(vehicle)
    local vehicleHandling = getVehicleHandling(vehicle)
    setVehicleHandling(vehicle, "mass", vehicleHandling["mass"] / juggernaut.mass)
    setVehicleHandling(vehicle, "engineAcceleration", vehicleHandling["engineAcceleration"] / juggernaut.acceleration)
    resetVehicleHandling(vehicle, "collisionDamageMultiplier")
    resetVehicleHandling(vehicle, "centerOfMass")
end

addEventHandler("onPowerupRequested", resourceRoot, handlePowerupRequest)
