local ECSFactory = require("src.ecs.factory")

local Brick = {}
Brick.__index = Brick

function Brick:new(x, y, width, height, resistance, colors)
    local entity = ECSFactory.createBrick(x or 0, y or 0, width or 75, height or 20, resistance or 1, colors)
    local this = setmetatable({ entity = entity }, Brick)
    return this
end

return Brick
