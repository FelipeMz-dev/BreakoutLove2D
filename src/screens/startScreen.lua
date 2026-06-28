local Screen = require("src.screens.screen")

local StartScreen = setmetatable({}, { __index = Screen })
StartScreen.__index = StartScreen

function StartScreen.new(navigator, progression, levelLoader)
    local self = setmetatable(Screen.new(), StartScreen)
    self.navigator = navigator
    self.progression = progression
    self.levelLoader = levelLoader
    return self
end

function StartScreen:enter(params)
    if self.progression then
        self.progression:load()
    end
end

function StartScreen:update(dt)
    if love.keyboard.isDown("return") then
        local totalLevels = 0
        if self.levelLoader and type(self.levelLoader.getLevels) == "function" then
            totalLevels = #self.levelLoader:getLevels()
        end
        if totalLevels == 0 and self.progression then
            totalLevels = #self.progression.levels
        end
        self.navigator:goTo("menu", { totalLevels = totalLevels })
    end
end

function StartScreen:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("BREAKOUT SOLID", 0, windowHeight * 0.4, windowWidth, "center")
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Presiona ENTER para comenzar", 0, windowHeight * 0.7, windowWidth, "center")
end

return StartScreen