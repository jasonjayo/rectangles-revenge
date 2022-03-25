-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here 

local ui = display.newGroup()
local titleText = display.newText({parent=ui, text="Ragna's Revenge", x=display.contentCenterX,y=0});

local player = display.newRect(display.contentCenterX, display.contentCenterY, 50, 50);
player.fill = {255, 255, 255}

local moveTimers = { left, right, up, down };

local movementKeys = { "left", "right", "up", "down"}

local function move(direction)
    if (direction == "left") then
        player.x = player.x - 5
    elseif (direction == "right") then
        player.x = player.x + 5
    elseif (direction == "up") then
        player.y = player.y - 5
    elseif (direction == "down") then
        player.y = player.y + 5
    end
end

local moveLeft = function() return move("left") end
local moveRight = function() return move("right") end
local moveUp = function() return move("up") end
local moveDown = function() return move("down") end

local function onKey(e)

    if (e.phase == "down") then
        
        if (e.keyName == "up") then
            moveTimers.up = timer.performWithDelay(50, moveUp, 0); 
        elseif (e.keyName == "down") then
            moveTimers.down = timer.performWithDelay(50, moveDown, 0);
        elseif (e.keyName == "left") then
            moveTimers.left = timer.performWithDelay(50, moveLeft, 0); 
        elseif (e.keyName == "right") then
            moveTimers.right = timer.performWithDelay(50, moveRight, 0);
        end

    elseif (e.phase == "up" and table.indexOf(movementKeys, e.keyName) ~=  nil) then
        timer.cancel(moveTimers[e.keyName])
    end

    return false
end

Runtime:addEventListener("key", onKey)