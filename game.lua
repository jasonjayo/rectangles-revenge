
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0,0);

local coins
local playerGroup
local ui
local enemiesUi
local indicatorsUi

local beginTime = os.time()

local state = { 
    playerHealth=50, 
    weapon = {
        damage  = { min=1, max=2 }
    },
    bullets     = 10,
    spawnRate   = 2500,
    stage       = 1
}
local player

-- local titleText = display.newText({parent=ui, text="Rectangles's Revenge", x=display.contentCenterX,y=10});
local healthBar

local ammo
local spawnRateIndicator

-- DEBUG
-- debug config options
local debug = {
    drawEnemyPlayerTriangles    = false,
    drawCollisionBoxes          = false,
    drawCentreIndicators        = false,
    drawBoundaryMarkers         = false,
}

-- DEBUG
if (debug.drawCollisionBoxes) then
    physics.setDrawMode("hybrid")
end
-- PLAYER

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
	print("pressed")
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
        -- prevents possible bug when an arrow key is pressed while window is out of focus and then window is subsequently focused
        if (moveTimers[e.keyName] ~= nil) then
            timer.cancel(moveTimers[e.keyName])
        end
    end

    return false
end


-- leftButton:addEventListener("tap", onMoveLeftTap)



if (debug.drawBoundaryMarkers) then
    display.newLine(0,0,0,display.contentHeight);
    display.newLine(display.contentWidth,0, display.contentWidth,display.contentHeight);
end

local spawningEnemies = {"triangle", "square"}
local liveEnemies = {}

-- enemy properties 
local enemies = {
    triangle={
        vertices    ={0,-25, 30,25, -30,25},
        colour      ={1,1,1},
        health      =1,
        speed       =3,
        strength    =2
    },
    square={
        vertices    ={-25,-25, 25,-25, 25,25, -25,25},
        colour      ={0.3,0.65,1},
        health      =2,
        speed       =4,
        strength    =4
    },
    pentagon= {
        vertices    ={0,-30, 30,-10, 20,30, -20,30, -30,-10},
        colour      ={245/255, 40/255, 145/255},
        health      =4,
        speed       =6,
        strength    =10
    },
    hexagon= {
        vertices    ={-30,10, -25,-15, 0,-30, 25,-15, 30,10, 15,30, -15,30},
        colour      ={0.2, 0, 0.4},
        health      =5,
        speed       =6,
        strength    =12
    },
    heptagon= {
        vertices    ={-25,-15, 0,-30, 25,-15, 30,10, 15,30, -15,30, -30,10},
        colour      ={1, 0.5, 0},
        health      =6,
        speed       =6,
        strength    =12
    },
    hexagon = {
        vertices    ={-30,0, -20,-22, 0,-30, 20,-22, 30,0, 20,22, 0,30, -20,22},
        colour      ={1, 0.16, 0},
        health      =10,
        speed       =4,
        strength    =12
    }
}

local weapons = {
    -- classic
    {
        damage  = { min=1, max=2 },
        name    = "Old Reliable"
    },
    -- can hit up to three enemies before being destroyed 
    {
        damage  = { min=1, max=2 },
        name    = "The Tripler"
    },
    -- more powerful than classic
    {
        damage  = { min=3, max=5 },
        name    = "The Enemy Destroyer"
    }
}

local maxHealth = 50


local function enemyBulletCollision(enemy, e)
    if (e.other.type == "bullet") then
        local bullet = e.other
        -- cancel transition so onComplete event doesn't try to delete this bullet after we've already deleted it here
        transition.cancel(bullet.transition)
        bullet:removeSelf()
        local damageDone = math.random(state.weapon.damage.min, state.weapon.damage.max) 
        print("damage done " .. damageDone)
        enemy.health = enemy.health - damageDone
        if enemy.health <= 0 then
            liveEnemies[enemy.id] = nil
            enemy:removeSelf()
        end
    end
end

local paint  = {
    type=  "image",
    filename ="arrow.png"
}

local damageTexture = {
    type = "image",
    filename="damage.png"
}



-- DEBUG
local playerIndicator
local enemyIndicator 
if (debug.drawCentreIndicators) then
    playerIndicator = display.newCircle(player.x, player.y, 5);
    enemyIndicator = display.newCircle(0,0,5)
end

function spawnEnemy()
    print("spawning")
    local index = math.random(1, #spawningEnemies)
    local shape = spawningEnemies[index]
    -- change y to -100, -50 before prod
    local enemy = display.newPolygon(enemiesUi, math.random(0, display.contentWidth), -50, enemies[shape].vertices);
    local id = os.time() + math.random(1, 9999)



    enemy.type = "enemy"
    enemy.shape = shape
    enemy.id = id
    enemy.health = enemies[shape].health

    -- enemy.fill = paint
    enemy:setFillColor(unpack(enemies[shape]["colour"]))


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

    local totalEnemies = 0

    for id, enemy in next, liveEnemies, nil do
        totalEnemies = totalEnemies + 1
        -- print("updating enemy " .. enemy.id)

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

        -- enemy:setLinearVelocity(l / 10, h/10)
        local speed = enemies[enemy.shape].speed
        enemy:setLinearVelocity(speed * l / 10, speed * h/10)

        -- DEBUG
        if (debug.drawCentreIndicators) then
            enemyIndicator:removeSelf()
            enemyIndicator = display.newCircle(enemy.x, enemy.y, 5)
            enemyIndicator:setFillColor(0.65,1.00,0.30)
            playerIndicator:removeSelf()
            playerIndicator = display.newCircle(player.x, player.y, 5);
            playerIndicator:setFillColor(0.5,0.5,0.5,1)
        end

        -- print("processed " .. totalEnemies .. " enemies")
        
    end
end

-- spawnEnemy()
local coinTimers = {}
local function restorePlayerHealth()
    state.playerHealth = state.playerHealth + math.random(1, 5)
end

local function restoreAmmo()
    state.bullets = state.bullets + math.random(5, 15)
end

local function onPlayerCollision(player, e)

    if (e.phase == "began") then
        -- print("player colliding with: " .. e.other.type)

        if (e.other.type == "enemy") then
            -- player:applyLinearImpulse(20, 20, player.x, player.y)
            -- player:applyForce(20, 20, player.x, player.y)
            state.playerHealth = state.playerHealth - enemies[e.other.shape].strength

        else if (e.other.type == "coin") then
            e.other:removeSelf()
            timer.cancel(coinTimers[e.other.id])
            table.remove(coinTimers, e.other.id)
            restorePlayerHealth()
            restoreAmmo()
            -- prevent propagation
            return true
        end
    end
end
end








local function deleteBullet(b)
    b:removeSelf()
end


local function fireWeapon(e) 

    if e.type == "down" then
        if (state.bullets > 0) then
            local bullet = display.newCircle(player.x, player.y, 4);
            bullet:setFillColor(1, 0.16, 0)
            physics.addBody(bullet,"dynamic");
            bullet.isSensor = true
            bullet.type = "bullet"
            state.bullets = state.bullets - 1
            -- keep a reference to the transition in the bullet itself so we can cancel it
            -- if the bullet hits something (an enemy) before it reaches its destination x and y
            -- and is deleted. else onComplete will try to delete a bullet that no longer exists.
            bullet.transition = transition.to(bullet, {x=e.x, y=e.y, onComplete=deleteBullet})
        end
    end

end


local function coinClick(e)
    if e.type == "down" then
        print(coinTimers[e.target.id])
        timer.cancel(coinTimers[e.target.id])
        table.remove(coinTimers, e.target.id)
        restoreAmmo()
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

local spawnEnemiesTimer = timer.performWithDelay(state.spawnRate, spawnEnemy, 0);
local function difficultyControl()
    print("running difficulty control...")
    timer.cancel(spawnEnemiesTimer)
    local elapsedTime = os.time() - beginTime
    state.spawnRate = math.max(2500 - (((os.time() - beginTime)) * 75), 1100)
    spawnEnemiesTimer = timer.performWithDelay(state.spawnRate, spawnEnemy, 0);
end


local function endGame() 
	composer.gotoScene("menu", {time=800, effect="crossFade"})
end

local function control()
    if state.playerHealth <= 0 and state.stage ~= "dead" then
        state.stage = "dead"
        -- -- restorePlayerHealth()
        -- timer.cancel(spawnCoinsTimer)
        -- timer.cancel(difficultyControlTimer)
        -- timer.cancel(updateEnemiesTimer)
        -- timer.cancel(spawnEnemiesTimer)
        display.newText({text="You ran out of health", x=display.contentCenterX, y=display.contentCenterY, fontSize=50});
        healthBar.width = 0
		timer.performWithDelay( 2000, endGame )
    end
    healthBar.width = (state.playerHealth / maxHealth) * 250
    if (state.playerHealth < 20) then
        healthBar:setFillColor(1, 0.3, 0.3, 1)
    end
    ammo.text = "Ammo: " .. state.bullets
    spawnRateIndicator.text = "Spawning every (ms): " .. state.spawnRate

    local elapsedTime = os.time() - beginTime
    if (elapsedTime >= 10 and table.indexOf(spawningEnemies,"pentagon") == nil) then
        table.insert(spawningEnemies,"pentagon")
    elseif (elapsedTime >= 30 and table.indexOf(spawningEnemies, "hexagon") == nil) then
        table.insert(spawningEnemies,"hexagon")
    elseif (elapsedTime >= 60 and table.indexOf(spawningEnemies, "heptagon") == nil) then
        table.insert(spawningEnemies, "heptagon")
    elseif (elapsedTime >= 120 and table.indexOf(spawningEnemies,"hexagon")) then
        table.insert(spawningEnemies, "hexagon")
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen



	physics.pause()

	coins = display.newGroup();
	sceneGroup:insert(coins)
	playerGroup = display.newGroup();
	sceneGroup:insert(playerGroup)
	ui = display.newGroup();
	sceneGroup:insert(ui)
	enemiesUi = display.newGroup();
	sceneGroup:insert(enemiesUi)
	indicatorsUi = display.newGroup();
	sceneGroup:insert(indicatorsUi)

	player = display.newRect(playerGroup, display.contentCenterX, display.contentCenterY, 100, 50);
	player.fill = {255, 255, 255}
	print("player x " .. player.x)

	physics.addBody(player,"kinematic",{density=1, friction=1, bounce=0});
	player.isFixedRotation = true
	healthBar = display.newRect(ui, display.contentCenterX, display.contentHeight - 25, 250, 12);
	healthBar:setFillColor(0.3, 1, 0.42)
	ammo = display.newText({parent=ui, text="Ammo: " .. state.bullets, x = 0, y = display.contentHeight - 50})
	spawnRateIndicator = display.newText({parent=ui, text="Spawning every (ms): " .. state.spawnRate, x = 0, y = display.contentHeight - 25})

	player.collision = onPlayerCollision
	player:addEventListener("collision")

	local difficultyControlTimer
	
	
	local spawnCoinsTimer
	
	local updateEnemiesTimer
	
	local controlTimer
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener("key", onKey)
		
		difficultyControlTimer = timer.performWithDelay(5000, difficultyControl, 0)
	
	
		spawnCoinsTimer = timer.performWithDelay(1000,spawnCoins,0);
		
		updateEnemiesTimer = timer.performWithDelay(1000, updateEnemies, 0);
		
		controlTimer = timer.performWithDelay(10, control, 0)
	
		
		Runtime:addEventListener("mouse", fireWeapon)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		timer.cancel(spawnCoinsTimer)
        timer.cancel(difficultyControlTimer)
        timer.cancel(updateEnemiesTimer)
        timer.cancel(spawnEnemiesTimer)
		timer.cancel(controlTimer)

		timer.cancel("coinExpiry")

		Runtime:removeEventListener("mouse", fireWeapon)
		Runtime:removeEventListener("key", onKey)
		physics.pause()
		composer.removeScene("game")

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
