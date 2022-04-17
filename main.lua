-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here 

local physics = require( "physics" )
physics.start()
physics.setGravity(0,0);


local ui = display.newGroup()
local titleText = display.newText({parent=ui, text="Rectangles's Revenge", x=display.contentCenterX,y=10});

-- DEBUG
-- debug config options
local debug = {
    drawEnemyPlayerTriangles= true,
    drawCollisionBoxes= true,
    drawCentreIndicators = true,
    drawBoundaryMarkers = true,
}

-- DEBUG
if (debug.drawCollisionBoxes) then
    physics.setDrawMode("hybrid")
end

-- PLAYER

local player = display.newRect(display.contentCenterX, display.contentCenterY, 100, 50);
player.fill = {255, 255, 255}

physics.addBody(player,"kinematic");

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



-- ENEMIES

local enemiesUi = display.newGroup()
local indicatorsUi = display.newGroup()

if (debug.drawBoundaryMarkers) then
    display.newLine(0,0, 0,display.contentHeight);
    display.newLine(display.contentWidth,0, display.contentWidth,display.contentHeight);
end

local spawningEnemies = {"triangle", "square", "pentagon"}
local liveEnemies = {}

-- enemy properties 
local enemies = {
    triangle={
        vertices={0,-25, 30,25, -30,25},
        colour={1,1,1},
        name="triangle"
    },
    square={
        strength=1,
        damage=1,
        vertices={-25,-25, 25,-25, 25,25, -25,25},
        name="square",
        colour={0.3,0.65,1}
    },
    pentagon= {
        vertices={0,-30, 30,-10, 20,30, -20,30, -30,-10},
        colour={245/255, 40/255, 145/255},
        name="pentagon"
    }
}


local paint  = {
    type=  "image",
    filename ="arrow.png"
}

-- DEBUG
local playerIndicator
local enemyIndicator 
if (debug.drawCentreIndicators) then
    playerIndicator = display.newCircle(player.x, player.y, 5);
    enemyIndicator = display.newCircle(0,0,5)
end

function spawnEnemy()
    local index = math.random(1, #spawningEnemies)
    local shape = spawningEnemies[index]
    local enemy = display.newPolygon(enemiesUi, math.random(0, display.contentWidth), math.random(-100, -50), enemies[shape].vertices);
    table.insert(liveEnemies, enemy)


    enemy:setFillColor(unpack(enemies[shape]["colour"]))
    enemy.fill = paint

    physics.addBody(enemy, "dynamic", {density=1, frction=1, bounce=0.8, shape=enemies[shape]["vertices"]})
    -- physics.pause()

    local l = player.x - enemy.x
    local h = player.y - enemy.y
    local hypot = math.sqrt(math.pow(l, 2) + math.pow(h, 2))

end

local direction = {x=1,y=1}

function setDirection()
    direction = {x=math.random(-1,1),y=math.random(-1,1)}
end

local enemyPlayerTriangles = {}

function updateEnemies()
    
    -- DEBUG
    if (debug.drawEnemyPlayerTriangles) then
        for i = 1, #enemyPlayerTriangles, 1 do
            enemyPlayerTriangles[i]:removeSelf()
        end
        enemyPlayerTriangles = {}
    end


    for i = 1, #liveEnemies, 1 do

        local l = (player.x - liveEnemies[i].x)
        local h = (player.y - liveEnemies[i].y)
        local hypot = (math.sqrt(math.pow(l, 2) + math.pow(h, 2)))

        -- DEBUG
        if (debug.drawEnemyPlayerTriangles) then
            table.insert(enemyPlayerTriangles, display.newLine(liveEnemies[i].x, liveEnemies[i].y, player.x, player.y, liveEnemies[i].x, player.y, liveEnemies[i].x, liveEnemies[i].y))
        end

        local angle = math.asin(l / hypot);

        if (h < 0) then
            liveEnemies[i].rotation = math.deg(angle)
        else
            transition.to(liveEnemies[i], {time=500, rotation = 180 - math.deg(angle)})
        end

        liveEnemies[i]:setLinearVelocity(l / 10, h/10)

        -- DEBUG
        if (debug.drawCentreIndicators) then
            enemyIndicator:removeSelf()
            enemyIndicator = display.newCircle(liveEnemies[i].x, liveEnemies[i].y, 5)
            enemyIndicator:setFillColor(0.65,1.00,0.30)
            playerIndicator:removeSelf()
            playerIndicator = display.newCircle(player.x, player.y, 5);
            playerIndicator:setFillColor(0.5,0.5,0.5,1)
        end
        
    end
end

spawnEnemy()

-- updateEnemies()

timer.performWithDelay(1000, updateEnemies, 0);

timer.performWithDelay(5000, spawnEnemy, 0);

-- local a = display.newPolygon(50, 50, enemies.pentagon.vertices);

-- to be worked on later
local state = { playerHealth=10 }

local function restorePlayerHealth()
    state.playerHealth = state.playerHealth + math.random(1, 5)
end


-- to be removed later

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
