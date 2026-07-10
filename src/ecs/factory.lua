local Entity = require("src.ecs.entity")
local Transform = require("src.ecs.components.transform")
local Velocity = require("src.ecs.components.velocity")
local Renderable = require("src.ecs.components.renderable")
local AudioPlayer = require("src.ecs.components.audioPlayer")
local Collider = require("src.ecs.components.collider")
local InputControlled = require("src.ecs.components.inputControlled")
local BallBehavior = require("src.ecs.components.ballBehavior")
local BrickBehavior = require("src.ecs.components.brickBehavior")

local Factory = {}

function Factory.createPaddle(x, y)
    local entity = Entity.new("paddle")
    entity:addTag("paddle")
    entity:addComponent(Transform.new(x, y, 100, 16))
    entity:addComponent(Velocity.new(0, 0))
    entity:addComponent(Renderable.new("assets/sprites/Trampoline.png", { 1, 1, 1 }, "sprite"))
    entity:addComponent(Collider.new("rect"))
    entity:addComponent(InputControlled.new(300))
    return entity
end

function Factory.createBall(x, y, radius, speed)
    local entity = Entity.new("ball")
    entity:addTag("ball")
    entity:addComponent(Transform.new(x, y, radius * 2, radius * 2))
    entity:addComponent(Velocity.new(0, 0))
    entity:addComponent(Renderable.new("assets/sprites/Baseball.png", { 1, 1, 1 }, "sprite"))
    entity:addComponent(AudioPlayer.new({
        { path = "assets/sounds/ball_hit.mp3", key = "ball_hit", volume = 0.8, loop = false },
        { path = "assets/sounds/ball_bounce.mp3", key = "ball_bounce", volume = 0.8, loop = false },
        { path = "assets/sounds/brick_hit.mp3", key = "brick_hit", volume = 0.7, loop = false },
        { path = "assets/sounds/brick_destroy.mp3", key = "brick_destroy", volume = 0.7, loop = false }
    }))
    entity:addComponent(Collider.new("circle"))
    entity:addComponent(BallBehavior.new(radius, speed))
    return entity
end

function Factory.createBrick(x, y, width, height, resistance, colors)
    local entity = Entity.new("brick")
    entity:addTag("brick")
    entity:addComponent(Transform.new(x, y, width or 75, height or 20))
    entity:addComponent(Renderable.new(nil, { 1, 1, 1 }, "rect"))
    entity:addComponent(Collider.new("rect"))
    entity:addComponent(BrickBehavior.new(resistance or 1, colors))
    return entity
end

return Factory
