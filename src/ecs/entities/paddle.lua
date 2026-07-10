local ECSFactory = require("src.ecs.factory")

local Paddle = {}
Paddle.__index = Paddle

function Paddle:new(x, y)
    local entity = ECSFactory.createPaddle(x or 1, y or 1)
    local this = setmetatable({
        entity = entity,
        speed = 300,
        aabb = { x = x or 1, y = y or 1, width = 100, height = 16 }
    }, Paddle)
    return this
end

return Paddle