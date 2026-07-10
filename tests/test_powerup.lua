local Factory = require("src.ecs.factory")

local powerup = Factory.createPowerup(100, 100)
assert(powerup ~= nil, "expected a powerup entity")
assert(powerup:hasTag("powerup"), "powerup entity should be tagged")
local behavior = powerup:getComponent("powerupBehavior")
assert(behavior ~= nil, "powerup should have powerup behavior")
assert(type(behavior.effectType) == "string", "powerup effect type should be a string")
print("powerup test passed")
