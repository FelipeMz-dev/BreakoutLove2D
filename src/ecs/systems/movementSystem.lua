local System = require("src.ecs.system")

local MovementSystem = {}

function MovementSystem.new()
    local self = System.new()
    setmetatable(self, { __index = MovementSystem })
    return self
end

function MovementSystem:update(dt, world)
    local screenWidth = (world and world.context and world.context.screenWidth) or love.graphics.getWidth()
    local screenHeight = (world and world.context and world.context.screenHeight) or love.graphics.getHeight()
    local removals = {}

    for _, entity in ipairs(world.entities) do
        if entity:hasTag("paddle") then
            local transform = entity:getComponent("transform")
            local input = entity:getComponent("inputControlled")
            if transform and input then
                local dx = 0
                if love.keyboard.isDown("left") then
                    dx = -input.speed
                elseif love.keyboard.isDown("right") then
                    dx = input.speed
                end

                transform.x = transform.x + dx * dt
                if transform.x < 0 then
                    transform.x = 0
                elseif transform.x + transform.width > screenWidth then
                    transform.x = screenWidth - transform.width
                end
            end
        elseif entity:hasTag("ball") then
            local transform = entity:getComponent("transform")
            local velocity = entity:getComponent("velocity")
            local ballBehavior = entity:getComponent("ballBehavior")
            if transform and velocity and ballBehavior and not ballBehavior.stuck then
                transform.x = transform.x + velocity.dx * dt
                transform.y = transform.y + velocity.dy * dt

                local distance = math.sqrt(
                    velocity.dx * velocity.dx +
                    velocity.dy * velocity.dy
                ) * dt

                transform.angle = transform.angle + distance / ballBehavior.radius
            end
        elseif entity:hasTag("powerup") then
            local transform = entity:getComponent("transform")
            local powerupBehavior = entity:getComponent("powerupBehavior")
            if transform and powerupBehavior and powerupBehavior.active then
                transform.y = transform.y + (powerupBehavior.fallSpeed or 120) * dt
                if transform.y > screenHeight + 20 then
                    table.insert(removals, entity)
                end
            end
        end
    end

    for _, entity in ipairs(removals) do
        world:removeEntity(entity)
    end
end

return MovementSystem
