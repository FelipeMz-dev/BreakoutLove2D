-- Breakout Game in Love2D
-- Navigation between screens with an internal game state machine

local Navigator = require("src.core.navigator")
local GameScreen = require("src.scenes.gameScene")
local StartScreen = require("src.scenes.startScene")
local MenuScreen = require("src.scenes.menuScene")
local ProgressionManager = require("src.utils.progressionManager")
local LevelLoader = require("src.utils.levelLoader")

local navigator
local progression
local levelLoader
local audioLoop

function love.load()
    progression = ProgressionManager.new()
    progression:load()

    audioLoop = love.audio.newSource("assets/sounds/music.mp3", "stream")
    audioLoop:setLooping(true)
    audioLoop:setVolume(0.5)

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

function loadSound (path)
    local info = love.filesystem.getInfo( path )
    if info then
        return love.audio.newSource( path, "static" )
    end
end

function playLoopSound()
    if not audioLoop:isPlaying() then
        audioLoop:play()
    end
end

function stopLoopSound()
    if audioLoop:isPlaying() then
        audioLoop:stop()
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