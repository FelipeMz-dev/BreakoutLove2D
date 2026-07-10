local System = require("src.ecs.system")

local CollisionSystem = {}

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

function CollisionSystem:update(dt, world)
    local screenWidth = (world and world.context and world.context.screenWidth) or love.graphics.getWidth()
    local screenHeight = (world and world.context and world.context.screenHeight) or love.graphics.getHeight()

    local ballEntity = world:getEntityByTag("ball")
    if not ballEntity then
        return
    end

    local ballTransform = ballEntity:getComponent("transform")
    local ballBehavior = ballEntity:getComponent("ballBehavior")
    local velocity = ballEntity:getComponent("velocity")

    if not (ballTransform and ballBehavior and velocity) or ballBehavior.stuck then
        return
    end

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

    local paddleEntity = world:getEntityByTag("paddle")
    if paddleEntity then
        local paddleTransform = paddleEntity:getComponent("transform")
        if paddleTransform and overlaps(ballLeft, ballTop, radius * 2, radius * 2, paddleTransform.x, paddleTransform.y, paddleTransform.width, paddleTransform.height) then
            ballTransform.y = paddleTransform.y - radius - 1
            local relativeImpact = (ballTransform.x - (paddleTransform.x + paddleTransform.width * 0.5)) / (paddleTransform.width * 0.5)
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
    end

    local bricks = world:getEntitiesByTag("brick")
    for _, brickEntity in ipairs(bricks) do
        local brickBehavior = brickEntity:getComponent("brickBehavior")
        local brickTransform = brickEntity:getComponent("transform")
        if brickBehavior and brickBehavior.active and brickTransform and overlaps(ballLeft, ballTop, radius * 2, radius * 2, brickTransform.x, brickTransform.y, brickTransform.width, brickTransform.height) then
            local overlapX = math.min(ballRight, brickTransform.x + brickTransform.width) - math.max(ballLeft, brickTransform.x)
            local overlapY = math.min(ballBottom, brickTransform.y + brickTransform.height) - math.max(ballTop, brickTransform.y)
            if overlapX < overlapY then
                local normalX = ballTransform.x < brickTransform.x + brickTransform.width * 0.5 and -1 or 1
                ballBehavior:reflect(normalX, 0)
                if normalX < 0 then
                    ballTransform.x = brickTransform.x - radius - 1
                else
                    ballTransform.x = brickTransform.x + brickTransform.width + radius + 1
                end
            else
                local normalY = ballTransform.y < brickTransform.y + brickTransform.height * 0.5 and -1 or 1
                ballBehavior:reflect(0, normalY)
                if normalY < 0 then
                    ballTransform.y = brickTransform.y - radius - 1
                else
                    ballTransform.y = brickTransform.y + brickTransform.height + radius + 1
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

            local session = world.context and world.context.session
            if session and type(session.addScore) == "function" then
                session:addScore(destroyed and 10 or 3)
            end
            break
        end
    end
end

return CollisionSystem
