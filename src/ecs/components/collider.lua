local Collider = {}
Collider.__index = Collider

function Collider.new(shape, x, y, width, height)
    return setmetatable({
        name = "collider",
        shape = shape or "rect",
        aabb = { x = x or 0, y = y or 0, width = width or 0, height = height or 0 }
    }, Collider)
end

function Collider:updateFromTransform(transform)
    if not transform or not self.aabb then
        return self
    end

    self.aabb.x = transform.x or 0
    self.aabb.y = transform.y or 0
    self.aabb.width = transform.width or 0
    self.aabb.height = transform.height or 0
    return self
end

return Collider
