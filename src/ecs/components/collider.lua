local Collider = {}
Collider.__index = Collider

function Collider.new(shape)
    return setmetatable({
        name = "collider",
        shape = shape or "rect"
    }, Collider)
end

return Collider
