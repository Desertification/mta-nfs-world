local juggernaut = {
    mass = 4,
    acceleration = 1.5,
    collision = 0,
    com = -10,
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
    if (not isPowerupRecharging(client, powerup)) and isPlayerDriving(client) then
        activatePowerup(client, powerup)
        setTimer(stopPowerup, powerupDuration[powerup], 1, player, powerup)
        setTimer(rechargePowerup, powerupDuration[powerup], 1, player, powerup)
    end
end

function isPowerupRecharging(player, powerup)
    local serial = getPlayerSerial(player)
    return powerupRecharging[serial][powerup] == true
end

function setPowerupRecharging(player, powerup, bool)
    local serial = getPlayerSerial(player)
    powerupRecharging[serial][powerup] = bool
end

function activatePowerup(player, powerup)
    setPowerupRecharging(player, powerup, true)
    --temp
    activateJuggernaut(getPedOccupiedVehicle(player))
    --temp
end

function stopPowerup(player, powerup)
    triggerClientEvent(player, "onPowerupStopped", player, powerup)
    --temp
    stopJuggernaut(getPedOccupiedVehicle(player))
    --temp
end

function rechargePowerup(player, powerup)
    setPowerupRecharging(player, powerup, false)
    triggerClientEvent(player, "onPowerupRecharged", player, powerup)
end

function isPlayerDriving(player)
    if getPedOccupiedVehicle(player) then
        return getPedOccupiedVehicleSeat(player) == 0
    end
    return false
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

function addPlayerToRechargingTable(playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber)
    powerupRecharging[playerSerial] = {}
end

addEventHandler("onPowerupRequested", resourceRoot, handlePowerupRequest)
addEventHandler("onPowerupRequested", resourceRoot, handlePowerupRequest)
addEventHandler ("onPlayerConnect", getRootElement(), addPlayerToRechargingTable)

for k, player in ipairs(getElementsByType("player")) do
    addPlayerToRechargingTable(nil, nil, getPlayerSerial(player))
end