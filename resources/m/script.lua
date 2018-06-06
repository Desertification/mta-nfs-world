local spawnX, spawnY, spawnZ = 1959.55, -1714.46, 10

function joinHandler()
	spawnPlayer(source, spawnX, spawnY, spawnZ)
	fadeCamera(source, true)
	setCameraTarget(source, source)
	outputChatBox("Welcome to My Server", source)
end

addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function createVehicleForPlayer(player, command, vehicleModel)
    local x,y,z = getElementPosition(player) -- get the position of the player
	x = x + 5 -- add 5 units to the x position

	if vehicleModel then
		vehicleModel = tonumber(vehicleModel)
	else
		vehicleModel = 411
	end

	local createdVehicle = createVehicle(vehicleModel,x,y,z) 

	if (createdVehicle == false) then
		outputChatBox("Failed to create vehicle.",thePlayer)
	end
end

function applyJuggernautForPlayer(player, command)
	local vehicle = getPedOccupiedVehicle(player)
	local vehicleHandling = getVehicleHandling(vehicle)

    setVehicleHandling(vehicle, "mass", vehicleHandling["mass"]*4)
	setVehicleHandling(vehicle, "engineAcceleration", vehicleHandling["engineAcceleration"]*4)
end

function setTopSpeedForPlayerVehicle(player, command, speed)
	local vehicle = getPedOccupiedVehicle(player)
	local vehicleHandling = getVehicleHandling(vehicle)

	if speed then
		speed = tonumber(speed)
	else
		outputChatBox("No top speed given",thePlayer)
		return
	end
	setVehicleHandling(vehicle, "maxVelocity", speed)
end

function setHandlingForPlayerVehicle(player, command, property, value)
	local vehicle = getPedOccupiedVehicle(player)
	setVehicleHandling(vehicle, property, tonumber(value))
end

function resetHandlingForPlayerVehicle(player, command)
	local vehicle = getPedOccupiedVehicle(player)
	setVehicleHandling (vehicle, true)
end

function respawnPlayer()
	local x,y,z = getElementPosition(source)
	spawnPlayer(source, x, y, z)
end

addEventHandler("onPlayerWasted", root, respawnPlayer)


addCommandHandler("car", createVehicleForPlayer)
addCommandHandler("boost", applyJuggernautForPlayer)
addCommandHandler("topspeed", setTopSpeedForPlayerVehicle)
addCommandHandler("stat", setHandlingForPlayerVehicle)
addCommandHandler("reset", resetHandlingForPlayerVehicle)
