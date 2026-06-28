local Screen = {}
Screen.__index = Screen

function Screen.new()
    return setmetatable({}, Screen)
end

function Screen:enter(params) end
function Screen:exit() end
function Screen:update(dt) end
function Screen:draw() end
function Screen:mousemoved(mx, my, ...) end
function Screen:mousepressed(x, y, button, ...) end
function Screen:keypressed(key, ...) end

return Screen
