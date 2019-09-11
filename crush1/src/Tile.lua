--[[
   CMPE40032
    Candy Crush Clone (Match 3 Game)

    -- Tile Class --



    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.shiny = math.random(1, 15) == 1 and true or false

    self.psystem = love.graphics.newParticleSystem(love.graphics.newImage('graphics/shiny.png'), 70)

    self.psystem:setParticleLifetime(1, 3)
    self.psystem:setEmissionRate(4)
    self.psystem:setLinearAcceleration(-10, 0, 10, 20)
    self.psystem:setAreaSpread('normal', 6, 6)

    self.psystem:setColors(
        215,
        255,
        0,
        255,
        215,
        255,
        0,
        255
    )
    self.psystem:emit(4)
end

function Tile:update(dt)
    self.psystem:update(dt)
end



function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.shiny then
        love.graphics.draw(self.psystem, self.x + x + 14, self.y + y + 10)
    end
end