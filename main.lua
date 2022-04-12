-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here 

local ui = display.newGroup()
local titleText = display.newText({parent=ui, text="Rectangles's Revenge", x=display.contentCenterX,y=10});

-- local player = display.newRect(display.contentCenterX, display.contentCenterY, 100, 50);
-- player.fill = {255, 255, 255}

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

-- leftButton:addEventListener("tap", onMoveLeftTap)

-- enemies



-- boundary markers
display.newLine(0,0, 0,display.contentHeight);
display.newLine(display.contentWidth,0, display.contentWidth,display.contentHeight);

-- triangle
local triangle = {0,0, 100,200, -100,200}

-- square
local square = {0,0, 100,0, 100,100, 0,100}

-- pentagon
local pentagon = {0,0, 80,60, 60,150, -60,150, -80,60}
-- local a = display.newPolygon(0+100, display.contentHeight/2, pentagon);
-- a:scale(0.4, 0.4)
-- a:setFillColor(245/255, 40/255, 145/255)


local spawningEnemies = {triangle, square, pentagon}
local liveEnemies = {}

for i = 1, 5, 1 do
    local index = math.random(1, #spawningEnemies)
    local a = display.newPolygon(math.random(50, 500), math.random(50, 250), spawningEnemies[index]);
    table.insert(liveEnemies, a)
    a:scale(0.4, 0.4)
    a:setFillColor(245/255, 40/255, 145/255)
end

local direction = {x=1,y=1}

function setDirection()
    direction = {x=math.random(-1,1),y=math.random(-1,1)}
end



function updateEnemies()
    for i = 1, #liveEnemies, 1 do
        liveEnemies[i].x = liveEnemies[i].x + (math.random(1, 10) * direction["x"])
        liveEnemies[i].y = liveEnemies[i].y + (math.random(10, 10) * direction["y"])
    end
end


timer.performWithDelay(100, updateEnemies, 0);

timer.performWithDelay(1000, setDirection, 0);










local function polygon(sides, sideLength)

    local angle = math.rad(360 / sides)


    local a = math.round(sideLength * math.abs(math.sin(angle)))
    local b = math.round(sideLength * math.abs(math.cos(angle)))

    local prevX = 0
    local prevY = 0

    local x = 0
    local y = 0

    local vertices = {0,0}

    for i = 1, sides - 2, 1 do

        if ((i > sides / 4) and (i < (sides / 4) * 3)) then
            x = prevX + b
        else
            x = prevX - b
        end

        if ((sides / 2 ~= i) and (sides ~= i)) then
            if i < sides / 2 then
                -- print("y is " .. y .. " i is " .. i .. " and subtracting from y " .. b)
                y = prevY - a    
            else 
                -- print("y is " .. y .. " i is " .. i .. " and adding to y " .. b)
                y = prevY + a
            end
        end

        table.insert(vertices, x)
        table.insert(vertices, y)

        prevX = x
        prevY = y

    end

    return vertices

end






local state = { playerHealth=10 }

local function restorePlayerHealth()
    state.playerHealth = state.playerHealth + math.random(1, 5)
end


