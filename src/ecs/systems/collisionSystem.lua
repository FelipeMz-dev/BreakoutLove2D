local System = require("src.ecs.system")
local ECSFactory = require("src.ecs.factory")

local CollisionSystem = {}

local function applyPowerupEffect(world, powerupBehavior, paddleTransform)
    if not powerupBehavior or not powerupBehavior.active then
        return false
    end

    local effectType = powerupBehavior.effectType
    if effectType == "expand_paddle" then
        paddleTransform.width = math.min((paddleTransform.width or 100) + 30, 180)
        return true
    end

    if effectType == "multi_ball" then
        local sourceBall = world:getEntityByTag("ball")
        local sourceTransform = sourceBall and sourceBall:getComponent("transform")
        local sourceBehavior = sourceBall and sourceBall:getComponent("ballBehavior")

        if sourceBall and sourceTransform and sourceBehavior then
            local duplicateBall = ECSFactory.createBall(sourceTransform.x, sourceTransform.y, sourceBehavior.radius, sourceBehavior.speed)
            local duplicateTransform = duplicateBall and duplicateBall:getComponent("transform")
            local duplicateBehavior = duplicateBall and duplicateBall:getComponent("ballBehavior")
            if duplicateBall and duplicateTransform and duplicateBehavior then
                duplicateTransform.x = sourceTransform.x + 8
                duplicateTransform.y = sourceTransform.y + 8
                duplicateBehavior.stuck = sourceBehavior.stuck
                if sourceBehavior.stuck then
                    duplicateBehavior:reset(duplicateTransform.x, duplicateTransform.y)
                else
                    duplicateBehavior:setDirection(sourceBehavior.angle, sourceBehavior.speed)
                end
                world:addEntity(duplicateBall)
                return true
            end
        end
        return false
    end

    if effectType == "slow_ball" then
        for _, ballEntity in ipairs(world:getEntitiesByTag("ball")) do
            local ballBehavior = ballEntity:getComponent("ballBehavior")
            if ballBehavior then
                ballBehavior.speed = math.max(180, ballBehavior.speed - 40)
                ballBehavior:setDirection(ballBehavior.angle, ballBehavior.speed)
            end
        end
        return true
    end

    return false
end

function CollisionSystem.new()
    local self = System.new()
    setmetatable(self, { __index = CollisionSystem })
    return self
end

local function overlaps(aX, aY, aW, aH, bX, bY, bW, bH)
    return aX < bX + bW
        and aX + aW > bX
        and aY < bY + bH
        and aY + aH > bY
end

local function syncColliderAABB(entity)
    local transform = entity and entity:getComponent("transform")
    local collider = entity and entity:getComponent("collider")

    if collider and transform then
        collider:updateFromTransform(transform)
    end

    return collider and collider.aabb
end

function CollisionSystem:update(dt, world)
    local screenWidth = (world and world.context and world.context.screenWidth) or love.graphics.getWidth()
    local screenHeight = (world and world.context and world.context.screenHeight) or love.graphics.getHeight()

    local balls = world:getEntitiesByTag("ball")
    if #balls == 0 then
        return
    end

    local paddleEntity = world:getEntityByTag("paddle")
    local paddleTransform = paddleEntity and paddleEntity:getComponent("transform")
    local paddleAABB = paddleEntity and syncColliderAABB(paddleEntity)

    for _, ballEntity in ipairs(balls) do
        local ballTransform = ballEntity:getComponent("transform")
        local ballBehavior = ballEntity:getComponent("ballBehavior")
        local velocity = ballEntity:getComponent("velocity")

        if ballTransform and ballBehavior and velocity and not ballBehavior.stuck then
            local radius = ballBehavior.radius
            local ballLeft = ballTransform.x - radius
            local ballTop = ballTransform.y - radius
            local ballRight = ballTransform.x + radius
            local ballBottom = ballTransform.y + radius

            if ballLeft <= 0 then
                ballTransform.x = radius
                ballBehavior:reflect(-1, 0)
                if type(ballBehavior.hit) == "function" then
                    ballBehavior:hit("ball_bounce")
                end
            elseif ballRight >= screenWidth then
                ballTransform.x = screenWidth - radius
                ballBehavior:reflect(1, 0)
                if type(ballBehavior.hit) == "function" then
                    ballBehavior:hit("ball_bounce")
                end
            end

            if ballTop <= 40 then
                ballTransform.y = 40 + radius
                ballBehavior:reflect(0, -1)
                if type(ballBehavior.hit) == "function" then
                    ballBehavior:hit("ball_bounce")
                end
            end

            if paddleTransform and paddleAABB and overlaps(ballLeft, ballTop, radius * 2, radius * 2, paddleAABB.x, paddleAABB.y, paddleAABB.width, paddleAABB.height) then
                ballTransform.y = paddleAABB.y - radius - 1

                local relativeImpact = (ballTransform.x - (paddleAABB.x + paddleAABB.width * 0.5)) / (paddleAABB.width * 0.5)
                relativeImpact = math.max(-1, math.min(1, relativeImpact))

                local maxAngle = math.rad(70)
                local launchAngle = math.pi / 2 - relativeImpact * maxAngle
                ballBehavior:setDirection(launchAngle, ballBehavior.speed + 5)

                local session = world.context and world.context.session
                if session and type(session.addScore) == "function" then
                    session:addScore(1)
                end
                if type(ballBehavior.hit) == "function" then
                    ballBehavior:hit("ball_hit")
                end
            end

            local bricks = world:getEntitiesByTag("brick")
            for _, brickEntity in ipairs(bricks) do
                local brickBehavior = brickEntity:getComponent("brickBehavior")
                local brickAABB = syncColliderAABB(brickEntity)

                if brickBehavior and brickBehavior.active and brickAABB and overlaps(ballLeft, ballTop, radius * 2, radius * 2, brickAABB.x, brickAABB.y, brickAABB.width, brickAABB.height) then
                    local overlapX = math.min(ballRight, brickAABB.x + brickAABB.width) - math.max(ballLeft, brickAABB.x)
                    local overlapY = math.min(ballBottom, brickAABB.y + brickAABB.height) - math.max(ballTop, brickAABB.y)

                    if overlapX < overlapY then
                        local normalX = ballTransform.x < brickAABB.x + brickAABB.width * 0.5 and -1 or 1
                        ballBehavior:reflect(normalX, 0)

                        if normalX < 0 then
                            ballTransform.x = brickAABB.x - radius - 1
                        else
                            ballTransform.x = brickAABB.x + brickAABB.width + radius + 1
                        end
                    else
                        local normalY = ballTransform.y < brickAABB.y + brickAABB.height * 0.5 and -1 or 1
                        ballBehavior:reflect(0, normalY)

                        if normalY < 0 then
                            ballTransform.y = brickAABB.y - radius - 1
                        else
                            ballTransform.y = brickAABB.y + brickAABB.height + radius + 1
                        end
                    end

                    local destroyed = brickBehavior:takeHit()
                    if type(ballBehavior.hit) == "function" then
                        if destroyed then
                            ballBehavior:hit("brick_destroy")
                        else
                            ballBehavior:hit("brick_hit")
                        end
                    end

                    if destroyed and math.random() < 0.35 then
                        local powerup = ECSFactory.createPowerup(
                            brickAABB.x + brickAABB.width * 0.5 - 9,
                            brickAABB.y + brickAABB.height * 0.5 - 9
                        )
                        world:addEntity(powerup)
                    end

                    local session = world.context and world.context.session
                    if session and type(session.addScore) == "function" then
                        session:addScore(destroyed and 10 or 3)
                    end
                    break
                end
            end
        end
    end

    if paddleTransform and paddleAABB then
        for _, powerupEntity in ipairs(world:getEntitiesByTag("powerup")) do
            local powerupBehavior = powerupEntity:getComponent("powerupBehavior")
            local powerupAABB = syncColliderAABB(powerupEntity)
            if powerupBehavior and powerupBehavior.active and powerupAABB and overlaps(paddleAABB.x, paddleAABB.y, paddleAABB.width, paddleAABB.height, powerupAABB.x, powerupAABB.y, powerupAABB.width, powerupAABB.height) then
                local applied = applyPowerupEffect(world, powerupBehavior, paddleTransform)
                if applied then
                    local gameState = world.context and world.context.gameState
                    if gameState and type(gameState.addPowerup) == "function" then
                        gameState:addPowerup(powerupBehavior.effectType)
                    end
                end

                powerupBehavior.active = false
                powerupBehavior.collected = true
                world:removeEntity(powerupEntity)
                break
            end
        end
    end
end

return CollisionSystem
