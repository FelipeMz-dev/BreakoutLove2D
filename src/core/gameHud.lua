local Button = require("src.ecs.entities.button")

local GameHud = {}

local function getPowerupColor(effectType)
    if effectType == "multi_ball" then
        return 1, 0.35, 0.75
    elseif effectType == "slow_ball" then
        return 1, 0.85, 0.2
    end
    return 0.25, 0.7, 1.0
end
GameHud.__index = GameHud

function GameHud.new(gameScreen)
    local self = setmetatable({}, GameHud)
    self.gameScreen = gameScreen
    self.currentStateName = "PAUSE"
    self.buttons = {}
    self.buttonWidth = 90
    self.buttonHeight = 30
    self.buttonGap = 8
    return self
end

function GameHud:setStateName(stateName)
    self.currentStateName = stateName or "PAUSE"
end

function GameHud:buildButtons(width)
    if #self.buttons > 0 then
        return
    end

    local startX = math.max(10, width - (self.buttonWidth * 3 + self.buttonGap * 2) - 12)
    local y = 8

    local pauseButton = Button:new("Pausa", startX, y, self.buttonWidth, self.buttonHeight)
    pauseButton:setAction(function()
        if self.gameScreen and type(self.gameScreen.togglePause) == "function" then
            self.gameScreen:togglePause()
        end
    end)

    local menuButton = Button:new("Menu", startX + self.buttonWidth + self.buttonGap, y, self.buttonWidth, self.buttonHeight)
    menuButton:setAction(function()
        if self.gameScreen and type(self.gameScreen.goToMenu) == "function" then
            self.gameScreen:goToMenu()
        end
    end)

    local returnButton = Button:new("Return", startX + (self.buttonWidth + self.buttonGap) * 2, y, self.buttonWidth, self.buttonHeight)
    returnButton:setAction(function()
        if self.gameScreen and type(self.gameScreen.restart) == "function" then
            self.gameScreen:restart()
        end
    end)

    table.insert(self.buttons, pauseButton)
    table.insert(self.buttons, menuButton)
    table.insert(self.buttons, returnButton)
end

function GameHud:handleMousePressed(mx, my, button)
    if button ~= 1 then
        return false
    end

    for _, buttonItem in ipairs(self.buttons) do
        buttonItem.hovered = buttonItem:isHovered(mx, my)
        if buttonItem.hovered then
            buttonItem:mousePressed(mx, my, button)
            return true
        end
    end

    return false
end

function GameHud:draw()
    local width = love.graphics.getWidth()
    self:buildButtons(width)

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, width, 44)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))

    local session = self.gameScreen and self.gameScreen.session
    local level = self.gameScreen and self.gameScreen.currentLevel or 1
    local score = session and session.score or 0
    local lives = session and session.lives or 0

    love.graphics.print("Nivel: " .. tostring(level), 12, 12)
    love.graphics.print("Score: " .. tostring(score), 140, 12)
    love.graphics.print("Lifes: " .. tostring(lives), 260, 12)

    local powerups = self.gameScreen and self.gameScreen.activePowerups or {}
    love.graphics.print("Powerups:", 360, 12)
    for index = 1, 3 do
        local x = 455 + (index - 1) * 22
        local position = #powerups - (3 - index)
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("line", x, 10, 18, 18)
        if powerups[position] then
            local r, g, b = getPowerupColor(powerups[position])
            love.graphics.setColor(r, g, b)
            love.graphics.rectangle("fill", x + 2, 12, 14, 14)
        end
    end

    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    for _, buttonItem in ipairs(self.buttons) do
        buttonItem.hovered = buttonItem:isHovered(mouseX, mouseY)
        buttonItem:render()
    end
end

return GameHud
