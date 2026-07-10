local PowerupBehavior = {}
PowerupBehavior.__index = PowerupBehavior

local effectDefinitions = {
    expand_paddle = { label = "Paddle+", color = { 0.25, 0.7, 1.0 } },
    multi_ball = { label = "Ball+", color = { 1.0, 0.35, 0.75 } },
    slow_ball = { label = "Slow", color = { 1.0, 0.85, 0.2 } }
}

function PowerupBehavior.new(effectType, fallSpeed)
    local selectedEffect = effectType or "expand_paddle"
    local definition = effectDefinitions[selectedEffect] or effectDefinitions.expand_paddle

    return setmetatable({
        name = "powerupBehavior",
        effectType = selectedEffect,
        displayName = definition.label,
        color = definition.color,
        fallSpeed = fallSpeed or 120,
        active = true,
        collected = false
    }, PowerupBehavior)
end

return PowerupBehavior
