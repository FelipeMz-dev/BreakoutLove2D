local Scene = {}
Scene.__index = Scene

function Scene.new()
    return setmetatable({}, Scene)
end

function Scene:enter(params) end
function Scene:exit() end
function Scene:update(dt) end
function Scene:draw() end
function Scene:mousemoved(mx, my, ...) end
function Scene:mousepressed(x, y, button, ...) end
function Scene:keypressed(key, ...) end

return Scene
