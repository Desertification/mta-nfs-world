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

local getSmoothRotationX = nil
local getSmoothRotationY = nil
local getSmoothRotationZ = nil
local getSmoothRadius = nil

local ROTATION_FILTER_LENGTH = 15
local RADIUS_FILTER_LENGTH = 20

local antiMovingSickness = false
if getPlayerName(_localPlayer) == "maxtorcd55" then
    antiMovingSickness = true
end

local raceCamera = false
local playerVehicle = nil
local previousVelocity = 0

setCameraTarget(_localPlayer, _localPlayer)

local function enableRaceCamera(vehicle)
    raceCamera = true
end

local function disableRaceCamera()
    raceCamera = false
    setCameraTarget(_localPlayer, _localPlayer)
end

local function initRaceCamera(vehicle)
    playerVehicle = vehicle

    getSmoothRotationX = movingAverageFactory(ROTATION_FILTER_LENGTH)
    getSmoothRotationY = movingAverageFactory(ROTATION_FILTER_LENGTH)
    getSmoothRotationZ = movingAverageFactory(ROTATION_FILTER_LENGTH)
    getSmoothRadius = movingAverageFactory(RADIUS_FILTER_LENGTH)
end

addEventHandler(
    "onClientPlayerVehicleEnter",
    _localPlayer,
    function(vehicle, seat)
        if seat == 0 then
            initRaceCamera(vehicle)
            if getCameraViewMode() == 5 then
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
                if raceCamera then
                    disableRaceCamera()
                    setCameraViewMode(4)
                else
                    playSFX("genrl", 52, 14, false)
                    enableRaceCamera()
                end
            end
            if getCameraViewMode() == 5 then
                disableRaceCamera()
            end
        end
    end
)

addEventHandler(
    "onClientPreRender",
    _root,
    function(deltaTime)
        if raceCamera then
            local x, y, z = getElementPosition(playerVehicle)
            local rx, ry, rz = getElementRotation(playerVehicle)
            local vx, vy, vz = getElementVelocity(playerVehicle)
            local velocity = _sqrt(vx * vx + vy * vy + vz * vz)

            local acceleration = (velocity - previousVelocity) / (deltaTime / 1000)
            previousVelocity = velocity

            local radius = RADIUS_NEUTRAL

            if not antiMovingSickness then
                radius = _min(RADIUS_MAX, _max(RADIUS_MIN, RADIUS_NEUTRAL + (6 * acceleration)))
                radius = getSmoothRadius(radius)
            end

            local angleZ = _rad(rz - 90)
            local angleX = _rad(rx + 90)

            -- smooth camera rotation
            local sinX = _sin(angleX)
            local cosX = _cos(angleX)
            local sinZ = _sin(angleZ)
            local cosZ = _cos(angleZ)

            local crx = sinX * cosZ
            local cry = sinX * sinZ
            local crz = cosX

            if antiMovingSickness then
                crz = getSmoothRotationZ(crz)
            else
                crx = getSmoothRotationX(crx)
                cry = getSmoothRotationY(cry)
                crz = getSmoothRotationZ(crz)
            end

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
