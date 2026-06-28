local State = {}
State.__index = State

function State.new()
    return setmetatable({}, State)
end

function State:enter() end
function State:exit() end
function State:update(dt) end
function State:draw() end

return State