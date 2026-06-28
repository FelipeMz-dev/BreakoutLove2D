local GameSession = {}
GameSession.__index = GameSession

function GameSession.new(initialLives)
    local self = setmetatable({}, GameSession)
    self.score = 0
    self.lives = initialLives or 3
    return self
end

function GameSession:addScore(points)
    self.score = self.score + points
end

function GameSession:loseLife()
    self.lives = self.lives - 1
end

function GameSession:isGameOver()
    return self.lives <= 0
end

return GameSession