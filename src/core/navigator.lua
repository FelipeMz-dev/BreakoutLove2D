local Navigator = {}
Navigator.__index = Navigator

function Navigator.new()
    local self = setmetatable({}, Navigator)
    self.screens = {}
    self.current = nil
    return self
end

function Navigator:addScreen(name, screen)
    self.screens[name] = screen
end

function Navigator:goTo(name, params)
    assert(self.screens[name], "No existe la pantalla: " .. tostring(name))

    if self.current and self.current.exit then
        self.current:exit()
    end

    self.current = self.screens[name]

    if self.current.enter then
        self.current:enter(params)
    end
end

function Navigator:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function Navigator:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

function Navigator:mousemoved(mx, my, ...)
    if self.current and self.current.mousemoved then
        self.current:mousemoved(mx, my, ...)
    end
end

function Navigator:mousepressed(x, y, button, ...)
    if self.current and self.current.mousepressed then
        self.current:mousepressed(x, y, button, ...)
    end
end

function Navigator:keypressed(key, ...)
    if self.current and self.current.keypressed then
        self.current:keypressed(key, ...)
    end
end

return Navigator
