local _sin = math.sin
local _cos = math.cos

local function getPointOnSphere(originX, originY, originZ, radius, angleX, angleZ)
    local sinX = _sin(angleX)
    local cosX = _cos(angleX)
    local sinZ = _sin(angleZ)
    local cosZ = _cos(angleZ)

    local x = originX + radius * sinX * cosZ
    local y = originY + radius * sinX * sinZ
    local z = originZ + radius * cosX

    return x, y, z
end
