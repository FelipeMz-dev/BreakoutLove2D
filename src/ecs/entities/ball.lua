local ECSFactory = require("src.ecs.factory")

local Ball = {}
Ball.__index = Ball

function Ball:new(x, y, radius, speed)
    local entity = ECSFactory.createBall(x or 0, y or 0, radius or 6, speed or 300)
    local this = setmetatable({
        entity = entity,
        radius = radius or 6,
        speed = speed or 300,
        aabb = { x = x or 0, y = y or 0, width = (radius or 6) * 2, height = (radius or 6) * 2 }
    }, Ball)
    return this
end

return Ball
