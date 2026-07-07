local AABB = {}
AABB.__index = AABB

function AABB.new(x, y, width, height)
    local self = setmetatable({}, AABB)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 0
    self.height = height or 0
    return self
end

function AABB:overlaps(other)
    if not other then
        return false
    end

    return self.x < other.x + other.width
        and self.x + self.width > other.x
        and self.y < other.y + other.height
        and self.y + self.height > other.y
end

function AABB:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

return AABB