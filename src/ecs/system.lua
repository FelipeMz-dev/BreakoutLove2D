local System = {}

function System.new()
    local self = {}
    setmetatable(self, { __index = System })
    return self
end

function System:update(dt, world)
end

function System:draw(world)
end

return System
