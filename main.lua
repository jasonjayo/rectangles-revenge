-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here 
math.randomseed( os.time() )
local coins = display.newGroup()
local playerGroup = display.newGroup()


local physics = require( "physics" )
physics.start()
physics.setGravity(0,0);
-- physics.setPositionIterations( 6 )

local state = { playerHealth=10 }
local ui = display.newGroup()
local titleText = display.newText({parent=ui, text="Rectangles's Revenge", x=display.contentCenterX,y=10});

local healthBar = display.newText({parent=ui, text="Health: " .. state.playerHealth, x=0,y=10});


-- DEBUG
-- debug config options
local debug = {
    drawEnemyPlayerTriangles= false,
    drawCollisionBoxes= false,
    drawCentreIndicators = false,
    drawBoundaryMarkers = false,
}

-- DEBUG
if (debug.drawCollisionBoxes) then
    physics.setDrawMode("hybrid")
end

-- PLAYER

local player = display.newRect(playerGroup, display.contentCenterX, display.contentCenterY, 100, 50);
player.fill = {255, 255, 255}

physics.addBody(player,"kinematic",{density=1, friction=1, bounce=0});
player.isFixedRotation = true

local moveTimers = { left, right, up, down };

local movementKeys = { "left", "right", "up", "down"}

local function move(direction)
    if (direction == "left") then
        player.x = player.x - 3
    elseif (direction == "right") then
        player.x = player.x + 3
    elseif (direction == "up") then
        player.y = player.y - 3
    elseif (direction == "down") then
        player.y = player.y + 3
    end
end

local moveLeft = function() return move("left") end
local moveRight = function() return move("right") end
local moveUp = function() return move("up") end
local moveDown = function() return move("down") end

local function onKey(e)

    if (e.phase == "down") then
        
        if (e.keyName == "up") then
            moveTimers.up = timer.performWithDelay(10, moveUp, 0); 
        elseif (e.keyName == "down") then
            moveTimers.down = timer.performWithDelay(10, moveDown, 0);
        elseif (e.keyName == "left") then
            moveTimers.left = timer.performWithDelay(10, moveLeft, 0); 
        elseif (e.keyName == "right") then
            moveTimers.right = timer.performWithDelay(10, moveRight, 0);
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


local function enemyBulletCollision(enemy, e)
    -- print("enemy colliding with " .. e.other.type)
    if (e.other.type == "bullet") then
        print(enemy.id)
        liveEnemies[enemy.id] = nil
        enemy:removeSelf()
    end
end

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
    -- change y to -100, -50 before prod
    local enemy = display.newPolygon(enemiesUi, math.random(0, display.contentWidth), math.random(0, 1), enemies[shape].vertices);
    local id = os.time() + math.random(1, 9999)


    enemy:setFillColor(unpack(enemies[shape]["colour"]))

    enemy.fill = paint
    enemy.type = "enemy"
    enemy.id = id

    enemy.collision = enemyBulletCollision
    enemy:addEventListener("collision")


    physics.addBody(enemy, "dynamic", {density=10, friction=1, bounce=0.8, shape=enemies[shape]["vertices"]})
    -- physics.pause()

    local l = player.x - enemy.x
    local h = player.y - enemy.y
    local hypot = math.sqrt(math.pow(l, 2) + math.pow(h, 2))

    liveEnemies[id] = enemy


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


    for id, enemy in next, liveEnemies, nil do

        print("updating enemy " .. enemy.id)

        local l = (player.x - enemy.x)
        local h = (player.y - enemy.y)
        local hypot = (math.sqrt(math.pow(l, 2) + math.pow(h, 2)))

        -- DEBUG
        if (debug.drawEnemyPlayerTriangles) then
            table.insert(enemyPlayerTriangles, display.newLine(enemy.x, enemy.y, player.x, player.y, enemy.x, player.y, enemy.x, enemy.y))
        end

        local angle = math.asin(l / hypot);

        -- sort consistency
        if (h < 0) then
            transition.to(enemy, {time=500, rotation = math.deg(angle)})
        else
            angle = 180 - math.deg(angle)
            transition.to(enemy, {time=500, rotation = angle})
        end

        enemy:setLinearVelocity(l / 10, h/10)

        -- DEBUG
        if (debug.drawCentreIndicators) then
            enemyIndicator:removeSelf()
            enemyIndicator = display.newCircle(enemy.x, enemy.y, 5)
            enemyIndicator:setFillColor(0.65,1.00,0.30)
            playerIndicator:removeSelf()
            playerIndicator = display.newCircle(player.x, player.y, 5);
            playerIndicator:setFillColor(0.5,0.5,0.5,1)
        end
        
    end
end

spawnEnemy()
local coinTimers = {}
local function restorePlayerHealth()
    state.playerHealth = state.playerHealth + math.random(1, 5)
end

local function onPlayerCollision(player, e)

    if (e.phase == "began") then
        print("player colliding with: " .. e.other.type)

        if (e.other.type == "enemy") then
            -- player:applyLinearImpulse(20, 20, player.x, player.y)
            -- player:applyForce(20, 20, player.x, player.y)
            state.playerHealth = state.playerHealth - 2

            print(state.playerHealth)
        else if (e.other.type == "coin") then
            print(coinTimers[e.other.id])
            timer.cancel(coinTimers[e.other.id])
            table.remove(coinTimers, e.other.id)
            restorePlayerHealth()
            e.other:removeSelf()
            -- prevent propagation
            return true
        end
    end
end
end



player.collision = onPlayerCollision
player:addEventListener("collision")


local function control()
    if state.playerHealth <= 0 then
        -- restorePlayerHealth()
    end
    healthBar.text = "Health: " .. state.playerHealth
end

local function deleteBullet(b)
    b:removeSelf()
end

local function fireWeapon(e) 

    if e.type == "down" then

        local bullet = display.newRect(player.x, player.y, 3, 20);
        bullet:setFillColor(1, 0.16, 0)
        physics.addBody(bullet,"dynamic");
        bullet.isSensor = true
        bullet.type = "bullet"

        transition.to(bullet, {x=e.x, y=e.y, onComplete=deleteBullet})
        
    end

end


-- updateEnemies()

local function coinClick(e)
    if e.type == "down" then
        print(coinTimers[e.target.id])
        timer.cancel(coinTimers[e.target.id])
        table.remove(coinTimers, e.target.id)
        restorePlayerHealth()
        e.target:removeSelf()
        -- prevent propagation
        return true
    end
end

local function removeCoin(e)
    e.source.params.coin:removeSelf()
    table.remove(coinTimers, e.source.params.coin.id)
end

local function spawnCoins()

    local coin = display.newCircle(coins, math.random(0, display.contentWidth), math.random(0, display.contentHeight), 10);
    coin:setFillColor(1,1,0.1)

    coin:addEventListener("mouse", coinClick)
    local expiryTimer = timer.performWithDelay(math.random(1000, 5000), removeCoin, 1, "coinExpiry")
    expiryTimer.params = {coin= coin}
    local id = os.time()
    coin.type = "coin"
    coin.id = id
    physics.addBody(coin,"dynamic");
    coin.isSensor = true
    coinTimers[id] = expiryTimer

end




timer.performWithDelay(10, control, 0)

timer.performWithDelay(1000,spawnCoins,0);

timer.performWithDelay(1000, updateEnemies, 0);

timer.performWithDelay(5000, spawnEnemy, 0);

Runtime:addEventListener("mouse", fireWeapon)

-- local a = display.newPolygon(50, 50, enemies.pentagon.vertices);

-- to be worked on later





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
