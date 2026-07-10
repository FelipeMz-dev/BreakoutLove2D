local ECSFactory = require("src.ecs.factory")

local Paddle = {}
Paddle.__index = Paddle

function Paddle:new(x, y)
    local entity = ECSFactory.createPaddle(x or 1, y or 1)
    local this = setmetatable({ entity = entity }, Paddle)
    return this
end

return Paddle