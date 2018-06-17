local _root = getRootElement()
local _localPlayer = getLocalPlayer()
local _sin = math.sin
local _cos = math.cos
local _rad = math.rad
local _min = math.min
local _max = math.max
local _sqrt = math.sqrt

local RADIUS_MAX = 11
local RADIUS_MIN = 6
local RADIUS_NEUTRAL = 7
local ROTATION_FILTER_LENGTH = 15
local RADIUS_FILTER_LENGTH = 20

local playerVehicle = nil
local getSmoothRotationX = nil
local getSmoothRotationY = nil
local getSmoothRotationZ = nil
local getSmoothRadius = nil

local antiMovingSickness = false
if getPlayerName(_localPlayer) == "maxtorcd55" then
    antiMovingSickness = true
end

local raceCameraInitialized = false
local raceCameraActive = false
local raceCameraLastUsed = false
local previousVelocity = 0

--only for script restarts because raceCamera could still be activated
setCameraTarget(_localPlayer, _localPlayer)

local function enableRaceCamera(vehicle)
    raceCameraActive = true
end

local function disableRaceCamera()
    if raceCameraActive then
        raceCameraActive = false
        setCameraTarget(_localPlayer, _localPlayer)
    end
end

local function initRaceCamera()
    if not (getPedOccupiedVehicleSeat(_localPlayer) == 0) then
        error("Player must be driving as vehicle")
    end

    playerVehicle = getPedOccupiedVehicle(_localPlayer)

    getSmoothRotationX = movingAverageFactory(ROTATION_FILTER_LENGTH)
    getSmoothRotationY = movingAverageFactory(ROTATION_FILTER_LENGTH)
    getSmoothRotationZ = movingAverageFactory(ROTATION_FILTER_LENGTH)
    getSmoothRadius = movingAverageFactory(RADIUS_FILTER_LENGTH)

    raceCameraInitialized = true
end

addEventHandler(
    "onClientPlayerVehicleEnter",
    _localPlayer,
    function(vehicle, seat)
        if seat == 0 then
            initRaceCamera()
            if raceCameraLastUsed then
                enableRaceCamera()
            end
        end
    end
)

addEventHandler(
    "onClientVehicleStartExit",
    _root,
    function(player, seat, door)
        if player == _localPlayer then
            disableRaceCamera()
        end
    end
)

addEventHandler(
    "onClientPlayerWasted",
    _localPlayer,
    function()
        disableRaceCamera()
    end
)

bindKey(
    "change_camera",
    "down",
    function(key, keyState, ...)
        if getPedOccupiedVehicle(_localPlayer) and getPedOccupiedVehicleSeat(_localPlayer) == 0 then
            if getCameraViewMode() == 0 then
                if raceCameraActive then
                    disableRaceCamera()
                    setCameraViewMode(4)
                    raceCameraLastUsed = false
                else
                    playSFX("genrl", 52, 14, false)
                    enableRaceCamera()
                    raceCameraLastUsed = true
                end
            end
            if getCameraViewMode() == 5 then
                disableRaceCamera()
                raceCameraLastUsed = false
            end
        end
    end
)

--optimized for performance, do NOT refactor!
addEventHandler(
    "onClientPreRender",
    _root,
    function(deltaTime)
        if raceCameraActive then
            --only for when script restarts and player is still in a vehicle
            if not raceCameraInitialized then
                initRaceCamera()
            end

            --generate position of camera relative to the vehicle
            local rx, ry, rz = getElementRotation(playerVehicle)
            local angleZ = _rad(rz - 90) --vehicle orientation correction
            local angleX = _rad(rx + 90) --vehicle orientation correction
            local sinX = _sin(angleX)
            local crx = sinX * _cos(angleZ)
            local cry = sinX * _sin(angleZ)
            local crz = _cos(angleX)
            if antiMovingSickness then
                crz = getSmoothRotationZ(crz)
            else
                crx = getSmoothRotationX(crx)
                cry = getSmoothRotationY(cry)
                crz = getSmoothRotationZ(crz)
            end

            --generate distance between camera and vehicle
            local radius = RADIUS_NEUTRAL
            if not antiMovingSickness then
                --change camera distance based on acceleration
                local vx, vy, vz = getElementVelocity(playerVehicle)
                local velocity = _sqrt(vx * vx + vy * vy + vz * vz)
                local acceleration = (velocity - previousVelocity) / (deltaTime / 1000)
                previousVelocity = velocity
                radius = _min(RADIUS_MAX, _max(RADIUS_MIN, RADIUS_NEUTRAL + (6 * acceleration)))
                radius = getSmoothRadius(radius)
                --prevent shaking camera at max velocity of vehicle
                if radius < RADIUS_NEUTRAL + 0.03 and radius > RADIUS_NEUTRAL - 0.03 then
                    radius = RADIUS_NEUTRAL
                end
            end

            local x, y, z = getElementPosition(playerVehicle)

            -- set camera position on edge of sphere
            local cx = x + radius * crx
            local cy = y + radius * cry
            local cz = z + 2 + radius * crz

            -- prevent camera from clipping below ground if on steep hill
            local groundPosition = getGroundPosition(cx, cy, z)
            if groundPosition > cz then
                cz = groundPosition + 0.2
            end

            setCameraMatrix(cx, cy, cz, x, y, z + 1)
        end
    end
)
