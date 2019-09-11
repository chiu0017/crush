--[[
    GD50
    Match-3 Remake
    -- Board Class --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level

    if self.level < 6 then
        self.tilesRange = self.level
    else
        self.tilesRange = 6
    end

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do

        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(math.min(18, self.level + 5)), math.random(self.tilesRange)))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

function Board:findMatches()
    local result
    for y = 1, 8 do
        for x = 1, 8 do
            if x ~= 8 then
                self:swapTiles(self.tiles[y][x], self.tiles[y][x + 1])

                local n_match = 1
                local colorToMatch = self.tiles[y][1].color

                for x2 = 2, 8 do
                    if colorToMatch == self.tiles[y][x2].color then
                        n_match = n_match + 1
                    else
                        if n_match >= 3 then
                            self:swapTiles(self.tiles[y][x], self.tiles[y][x + 1])
                            return true
                        else
                            colorToMatch = self.tiles[y][x2].color
                            n_match = 1
                        end
                    end

                    if n_match>= 3 then
                        self:swapTiles(self.tiles[y][x], self.tiles[y][x + 1])
                        return true
                    end
                end
            end

            colorToMatch = self.tiles[1][x].color
            n_match= 1

            for y2 = 2, 8 do

                if colorToMatch == self.tiles[y2][x].color then
                    n_match = n_match+ 1
                else
                    if n_match >= 3 then
                        self:swapTiles(self.tiles[y][x], self.tiles[y][x + 1])
                        return true
                    else
                        colorToMatch = self.tiles[y2][x].color
                        n_match = 1
                    end
                end

                if n_match >= 3 then
                    self:swapTiles(self.tiles[y][x], self.tiles[y][x + 1])
                    return true
                end
            end

            if x ~= 8 then
                self:swapTiles(self.tiles[y][x], self.tiles[y][x + 1])
            end
        end
    end

    for x = 1, 8 do
        for y = 1, 8 do
            if y ~= 8 then
                self:swapTiles(self.tiles[y][x], self.tiles[y + 1][x])

                local n_match = 1
                local colorToMatch = self.tiles[1][y].color

                for y2 = 2, 8 do

                    if colorToMatch == self.tiles[y2][x].color then
                        n_match = n_match + 1
                    else
                        if n_match >= 3 then
                            self:swapTiles(self.tiles[y][x], self.tiles[y + 1][x])
                            return true
                        else
                            colorToMatch = self.tiles[y2][x].color
                            n_match = 1
                        end
                    end

                    if n_match >= 3 then
                        self:swapTiles(self.tiles[y][x], self.tiles[y + 1][x])
                        return true
                    end
                end
            end

            colorToMatch = self.tiles[y][1].color
            n_match = 1

            for x2 = 2, 8 do

                if colorToMatch == self.tiles[y][x2].color then
                    n_match = n_match + 1
                else
                    if n_match >= 3 then
                        self:swapTiles(self.tiles[y][x], self.tiles[y + 1][x])
                        return true
                    else
                        colorToMatch = self.tiles[y][x2].color
                        n_match = 1
                    end
                end

                if n_match >= 3 then
                    self:swapTiles(self.tiles[y][x], self.tiles[y + 1][x])
                    return true
                end
            end

            if y ~= 8 then
                self:swapTiles(self.tiles[y][x], self.tiles[y + 1][x])
            end
        end
    end

    return false
end

function Board:swapTiles(alphaTile, betaTile, callback)
    local alphaGridX = alphaTile.gridX
    local alphaGridY = alphaTile.gridY
    local alphaX = alphaTile.x
    local alphaY = alphaTile.y

    local betaGridX = betaTile.gridX
    local betaGridY = betaTile.gridY
    local betaX = betaTile.x
    local betaY = betaTile.y

    local tempGridX = alphaGridX
    local tempX = alphaX
    local tempGridY = alphaGridY
    local tempY = alphaY

    alphaTile.gridX = betaTile.gridX
    alphaTile.gridY = betaTile.gridY

    betaTile.gridX = tempGridX
    betaTile.gridY = tempGridY

    self.tiles[alphaTile.gridY][alphaTile.gridX] = alphaTile
    self.tiles[betaTile.gridY][betaTile.gridX] = betaTile

    if callback ~= nil then
        callback()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local n_match = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        local shinyMatch = false
        n_match = 1

        -- every horizontal tile
        for x = 2, 8 do

            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                n_match = n_match + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                -- if we have a match of 3 or more up to now, add it to our matches table
                if n_match >= 3 then
                    local match = {}

                    for x2 = x - 1, x - n_match, -1 do
                        if self.tiles[y][x2].shiny == true then
                            shinyMatch = true
                            break
                        end
                    end

                    if shinyMatch == true then
                        for x2 = 8, 1, -1 do
                            table.insert(match, self.tiles[y][x2])
                        end
                    else
                        -- go backwards from here by n_match
                        for x2 = x - 1, x - n_match, -1 do
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                n_match = 1

                if shinyMatch then
                    break
                end

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if n_match >= 3 then
            local match = {}
            
            for x2 = 8, 8 - n_match, -1 do
                if self.tiles[y][x2].shiny == true then
                    shinyMatch = true
                    break
                end
            end

            if shinyMatch == true then
                for x2 = 8, 1, -1 do
                    table.insert(match, self.tiles[y][x2])
                end
            else
                -- go backwards from end of last row by n_match
                for x = 8, 8 - n_match + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        local shinyMatch = false
        n_match = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                n_match = n_match + 1
            else
                colorToMatch = self.tiles[y][x].color

                if n_match >= 3 then
                    local match = {}

                    for y2 = y - 1, y - n_match, -1 do
                        if self.tiles[y2][x].shiny == true then
                            shinyMatch = true
                            break
                        end
                    end

                    if shinyMatch == true then
                        for y2 = 8, 1, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                    else
                        for y2 = y - 1, y - n_match, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end

                n_match = 1

                if shinyMatch then
                    break
                end

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if n_match >= 3 then
            local match = {}
            
            -- go backwards from end of last row by n_match

            for y2 = 8, 8 - n_match, -1 do
                if self.tiles[y2][x].shiny == true then
                    shinyMatch = true
                    break
                end
            end

            if shinyMatch == true then
                for y2 = 8, 1, -1 do
                    table.insert(match, self.tiles[y2][x])
                end
            else
                for y = 8, 8 - n_match + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(math.min(18, self.level + 5)), math.random(self.tilesRange))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:update(dt)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:update(dt)
        end
    end
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end