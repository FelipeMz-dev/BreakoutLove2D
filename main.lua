-- Breakout Game in Love2D
-- Navigation between screens with an internal game state machine

local Navigator = require("src.core.navigator")
local GameScreen = require("src.screens.gameScreen")
local StartScreen = require("src.screens.startScreen")
local MenuScreen = require("src.screens.menuScreen")
local ProgressionManager = require("src.systems.progressionManager")
local LevelLoader = require("src.systems.levelLoader")

local navigator
local progression
local levelLoader

function love.load()
    progression = ProgressionManager.new()
    progression:load()

    levelLoader = LevelLoader.new()
    levelLoader:loadAll()
    print("[main] Niveles cargados en LevelLoader: " .. tostring(#levelLoader:getLevels()))

    navigator = Navigator.new()
    navigator:addScreen("start", StartScreen.new(navigator, progression, levelLoader))
    navigator:addScreen("menu", MenuScreen.new(navigator, progression, levelLoader))
    navigator:addScreen("game", GameScreen.new(navigator, progression, levelLoader))

    navigator:goTo("start")
end

function loadImage (path)
	local info = love.filesystem.getInfo( path )
	if info then
		return love.graphics.newImage( path )
	end
end

function love.update(dt)
    navigator:update(dt)
end

function love.draw()
    navigator:draw()
end

function love.mousemoved(mx, my, dx, dy, istouch)
    navigator:mousemoved(mx, my, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
    navigator:mousepressed(x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isrepeat)
    navigator:keypressed(key, scancode, isrepeat)
end