local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(states)
    local self = setmetatable({}, StateMachine)
    self.states = states or {}
    self.current = nil
    return self
end

function StateMachine:change(stateName, params)
    assert(self.states[stateName], "El estado '" .. stateName .. "' no existe.")

    if self.current and type(self.current.exit) == "function" then
        self.current:exit()
    end

    self.current = self.states[stateName]
    if self.current and type(self.current.enter) == "function" then
        self.current:enter(params)
    end
end

function StateMachine:update(dt)
    if self.current then
        self.current:update(dt)
    end
end

function StateMachine:draw()
    if self.current then
        self.current:draw()
    end
end

return StateMachine