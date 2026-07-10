local Velocity = {}
Velocity.__index = Velocity

function Velocity.new(dx, dy)
    return setmetatable({
        name = "velocity",
        dx = dx or 0,
        dy = dy or 0
    }, Velocity)
end

return Velocity
