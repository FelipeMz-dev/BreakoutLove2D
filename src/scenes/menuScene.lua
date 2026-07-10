local Scene = require("src.scenes.scene")
local LevelItem = require("src.ecs.entities.levelItem")

local MenuScreen = setmetatable({}, { __index = Scene })
MenuScreen.__index = MenuScreen

function MenuScreen.new(navigator, progression, levelLoader)
    local self = setmetatable(Scene.new(), MenuScreen)
    self.navigator = navigator
    self.progression = progression
    self.levelLoader = levelLoader
    self.totalLevels = 0
    
    return self
end

function MenuScreen:enter(params)
    self.totalLevels = params and params.totalLevels or 0
    print("[MenuScreen] enter params.totalLevels=" .. tostring(self.totalLevels))

    if self.levelLoader and type(self.levelLoader.getLevels) == "function" then
        local loadedLevels = self.levelLoader:getLevels()
        print("[MenuScreen] LevelLoader loaded " .. tostring(#loadedLevels) .. " levels")
        if #loadedLevels > 0 then
            self.totalLevels = #loadedLevels
        end
    else
        print("[MenuScreen] No levelLoader disponible")
    end

    if self.totalLevels == 0 and self.progression and self.progression.levels then
        self.totalLevels = #self.progression.levels
        print("[MenuScreen] Usando progreso fallback totalLevels=" .. tostring(self.totalLevels))
    end

    self:buildLevelItems()
    self:layoutLevelItems()

    playLoopSound()
end

function MenuScreen:update(dt)
    local hovering = false

    for _, levelItem in ipairs(self.levelItems) do
        levelItem:update(dt)
        if levelItem.hovered and not levelItem.locked then
            hovering = true
        end
    end

    if love.mouse and love.mouse.setCursor then
        if not self.cursorArrow then
            self.cursorArrow = love.mouse.getSystemCursor("arrow")
            self.cursorHand = love.mouse.getSystemCursor("hand")
        end

        love.mouse.setCursor(hovering and self.cursorHand or self.cursorArrow)
    end
end

function MenuScreen:mousemoved(mx, my)
    for _, levelItem in ipairs(self.levelItems) do
        levelItem:handleMouseMoved(mx, my)
    end
end

function MenuScreen:mousepressed(mx, my, button)
    if button ~= 1 then
        return
    end

    for _, levelItem in ipairs(self.levelItems) do
        levelItem:mousePressed(mx, my, button)
    end
end

function MenuScreen:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    love.graphics.clear(0.1, 0.1, 0.1)

    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("BREAKOUT SOLID", 0, windowHeight * 0.18, windowWidth, "center")

    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Selecciona un nivel", 0, windowHeight * 0.32, windowWidth, "center")

    for _, levelItem in ipairs(self.levelItems) do
        levelItem:render()
    end
end

function MenuScreen:exit() end

function MenuScreen:buildLevelItems()
    self.levelItems = {}

    local levelDefinitions = nil
    if self.levelLoader and type(self.levelLoader.getLevels) == "function" then
        levelDefinitions = self.levelLoader:getLevels()
        self.totalLevels = #levelDefinitions
    end

    if levelDefinitions and #levelDefinitions > 0 then
        for _, levelDef in ipairs(levelDefinitions) do
            local levelNumber = levelDef.id or #self.levelItems + 1
            local isLocked = false

            if self.progression and type(self.progression.isUnlocked) == "function" then
                isLocked = not self.progression:isUnlocked(levelNumber)
            elseif self.progression and self.progression.levels then
                isLocked = not self.progression.levels[levelNumber]
            end

            local item = LevelItem:new(levelNumber, 0, 0, isLocked)
            item:setAction(function()
                self:goToLevel(levelNumber)
            end)

            table.insert(self.levelItems, item)
        end
    elseif self.progression and self.progression.levels then
        for levelNumber, _ in pairs(self.progression.levels) do
            local isLocked = false
            if type(self.progression.isUnlocked) == "function" then
                isLocked = not self.progression:isUnlocked(levelNumber)
            elseif self.progression.levels then
                isLocked = not self.progression.levels[levelNumber]
            end

            local item = LevelItem:new(levelNumber, 0, 0, isLocked)
            item:setAction(function()
                self:goToLevel(levelNumber)
            end)

            table.insert(self.levelItems, item)
        end

        table.sort(self.levelItems, function(a, b)
            return a.number < b.number
        end)
        self.totalLevels = #self.levelItems
    else
        for levelNumber = 1, self.totalLevels do
            local isLocked = false

            if self.progression and type(self.progression.isUnlocked) == "function" then
                isLocked = not self.progression:isUnlocked(levelNumber)
            elseif self.progression and self.progression.levels then
                isLocked = not self.progression.levels[levelNumber]
            end

            local item = LevelItem:new(levelNumber, 0, 0, isLocked)
            item:setAction(function()
                self:goToLevel(levelNumber)
            end)

            table.insert(self.levelItems, item)
        end
    end
end

function MenuScreen:layoutLevelItems()
    if #self.levelItems == 0 then
        return
    end

    local columns = 3
    local gap = 24
    local item = self.levelItems[1]
    local itemWidth = item.width
    local itemHeight = item.height
    local rows = math.ceil(#self.levelItems / columns)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local totalWidth = columns * itemWidth + (columns - 1) * gap
    local totalHeight = rows * itemHeight + (rows - 1) * gap

    local startX = (windowWidth - totalWidth) * 0.5
    local startY = windowHeight * 0.6

    for index, levelItem in ipairs(self.levelItems) do
        local col = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        levelItem.x = startX + col * (itemWidth + gap)
        levelItem.y = startY + row * (itemHeight + gap)
    end
end

function MenuScreen:goToLevel(levelNumber)
    if self.navigator and type(self.navigator.goTo) == "function" then
        self.navigator:goTo("game", { level = levelNumber })
        return
    end

    print("Navegando al nivel " .. levelNumber)
end

return MenuScreen