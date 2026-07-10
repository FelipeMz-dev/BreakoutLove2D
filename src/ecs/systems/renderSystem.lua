local System = require("src.ecs.system")

local RenderSystem = {}

function RenderSystem.new()
    local self = System.new()
    setmetatable(self, { __index = RenderSystem })
    return self
end

function RenderSystem:draw(world)
    for _, entity in ipairs(world.entities) do
        local renderable = entity:getComponent("renderable")
        local transform = entity:getComponent("transform")
        if not (renderable and transform) then
            goto continue
        end

        if entity:hasTag("brick") then
            local brickBehavior = entity:getComponent("brickBehavior")
            if brickBehavior and brickBehavior.active then
                local color = brickBehavior.colors and brickBehavior.colors[brickBehavior.colorIndex] or renderable.color
                love.graphics.setColor(color[1], color[2], color[3])
                love.graphics.rectangle("fill", transform.x, transform.y, transform.width, transform.height)
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("line", transform.x, transform.y, transform.width, transform.height)
                love.graphics.setFont(love.graphics.newFont(12))
                love.graphics.print(brickBehavior.resistance, transform.x + 5, transform.y + 2)
            end
        elseif entity:hasTag("ball") then
            local image = renderable.image
            if image then
                local scale = (transform.width or 0) / image:getWidth()
                local offsetX = image:getWidth() / 2
                local offsetY = image:getHeight() / 2
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(image, transform.x, transform.y, 0, scale, scale, offsetX, offsetY)
            end
        elseif entity:hasTag("paddle") then
            local image = renderable.image
            if image then
                local scale = transform.width / image:getWidth()
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(image, transform.x, transform.y, 0, scale, scale)
            end
        elseif entity:hasTag("powerup") then
            local powerupBehavior = entity:getComponent("powerupBehavior")
            local color = (powerupBehavior and powerupBehavior.color) or renderable.color or { 1, 1, 1 }
            love.graphics.setColor(color[1], color[2], color[3])
            love.graphics.rectangle("fill", transform.x, transform.y, transform.width, transform.height)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", transform.x, transform.y, transform.width, transform.height)
        else
            local color = renderable.color or { 1, 1, 1 }
            love.graphics.setColor(color[1], color[2], color[3])
            love.graphics.rectangle("fill", transform.x, transform.y, transform.width, transform.height)
        end

        ::continue::
    end
end

return RenderSystem
