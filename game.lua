-- 
-- There are some debug options in this file that I used to give more info on the screen 
-- to help with fixing bugs. They're all disabled now, but I decided to leave the code in for 
-- assessment purposes. I've clearly marked the debug code throughout the file with DEBUG
-- 
local composer = require("composer")
local json = require("json")
local scene = composer.newScene()


local physics = require("physics")
physics.start()
physics.setGravity(0,0);


-- display groups
local playerGroup
local ui
local enemiesUi
local indicatorsUi

local backgroundImage

local coins

local beginTime = os.time()

-- health and ammo maximums
local maxHealthBarWidth = 200
local maxHealth = 50
local maxAmmoBarHeight = 40
local maxAmmo = 40

-- audio
local shootSound = audio.loadSound("laser3.ogg")
local playerDamageSound = audio.loadSound("zap2.ogg")
local enemyDamageSound = audio.loadSound("twoTone2.ogg");
local coinSound = audio.loadSound("tone1.ogg")
local music = audio.loadStream("music.mp3")
audio.reserveChannels( 1 )
audio.setVolume( 0.5, { channel=1 } )

-- textures
local coinTexture  = {
    type=  "image",
    filename ="coin_texture.png"
}
local bulletTexture = {
    type = "image",
    filename = "bullet_texture.png"
}

-- initial state
local state = { 
    -- nil values are set below
    playerHealth=50,
    money       = nil,
    score       = 0,
    weapon      = nil,
    bullets     = maxAmmo,
    -- initially spawning 1 enemy every 2500 ms
    spawnRate   = 2500,
    stage       = 1
}

-- some values persist from session to session (e.g., money)
-- these are brought in from a json file in main.lua and stored in initialState
-- we now need to set our actual state variables here to reflect them
local initialState = composer.getVariable("initialState");
state.money = initialState.money
state.weaponsOwned = initialState.weaponsOwned
state.weapon = initialState.weapon
state.highscore = initialState.highscore

local player

local healthBar
local healthBarBackground

local ammoText
local ammo
local spawnRateIndicator
local moneyIndicator
local moneyCounter

local score
local coinTimers = {}

-- timers
local controlTimer
local difficultyControlTimer
local spawnCoinsTimer
local updateEnemiesTimer
local spawnEnemiesTimer

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
-- movement
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
            moveTimers.up = timer.performWithDelay(10, moveUp, 0, "movement"); 
        elseif (e.keyName == "down") then
            moveTimers.down = timer.performWithDelay(10, moveDown, 0, "movement");
        elseif (e.keyName == "left") then
            moveTimers.left = timer.performWithDelay(10, moveLeft, 0, "movement"); 
        elseif (e.keyName == "right") then
            moveTimers.right = timer.performWithDelay(10, moveRight, 0, "movement");
        end

    elseif (e.phase == "up" and table.indexOf(movementKeys, e.keyName) ~=  nil) then
        -- prevents possible bug when an arrow key is pressed while window is out of focus and then window is subsequently focused
        if (moveTimers[e.keyName] ~= nil) then
            timer.cancel(moveTimers[e.keyName])
        end
    end

    return false
end


-- DEBUG
if (debug.drawBoundaryMarkers) then
    display.newLine(0,0,0,display.contentHeight);
    display.newLine(display.contentWidth,0, display.contentWidth,display.contentHeight);
end

-- ENEMIES
-- only triangles and squares can spawn at the beginning. this list is updated as game progresses and gets harder
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
        colour      ={0.4, 0, 0.8},
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
    octagon = {
        vertices    ={-30,0, -20,-22, 0,-30, 20,-22, 30,0, 20,22, 0,30, -20,22},
        colour      ={1, 0.16, 0},
        health      =10,
        speed       =4,
        strength    =12
    }
}

-- event listener callback
local function enemyBulletCollision(enemy, e)
    if (e.other.type == "bullet") then
        -- deal with bullet
        local bullet = e.other
        -- cancel transition so onComplete event doesn't try to delete this bullet after we've already deleted it here
        bullet.health = bullet.health - 1
        if (bullet.health <= 0) then
            transition.cancel(bullet.transition)
            bullet:removeSelf()
        end
        -- deal with enemy
        local damageDone = math.random(state.weapon.damage.min, state.weapon.damage.max) 
        enemy.health = enemy.health - damageDone
        -- enemy gets more transparent the weaker they are
        transition.to(enemy, {time=100, alpha = (enemy.health / enemies[enemy.shape].health)})
        audio.play(enemyDamageSound);
        -- remove enemy if dead
        if enemy.health <= 0 then
            liveEnemies[enemy.id] = nil
            enemy:removeSelf()
        end
    end
end

-- DEBUG
local playerIndicator
local enemyIndicator 
if (debug.drawCentreIndicators) then
    playerIndicator = display.newCircle(player.x, player.y, 5);
    enemyIndicator = display.newCircle(0,0,5)
end

-- spawns enemies
local function spawnEnemy()
    -- pick random enemy to spawn
    local index = math.random(1, #spawningEnemies)
    local shape = spawningEnemies[index]
    -- enemies always come from the top of the screen - this is by design to make things slightly easier & more predictable for player 
    local enemy = display.newPolygon(enemiesUi, math.random(0, display.contentWidth), -50, enemies[shape].vertices);
    -- generate random id for enemy
    local id = os.time() + math.random(1, 9999)

    -- set properties for this enemy. these are read later in event callbacks to understand what kind of enemy we're dealing with
    enemy.type = "enemy"
    enemy.shape = shape
    enemy.id = id
    enemy.health = enemies[shape].health

    enemy:setFillColor(unpack(enemies[shape]["colour"]))

    -- add enemy-bullet collision event listener
    enemy.collision = enemyBulletCollision
    enemy:addEventListener("collision")

    physics.addBody(enemy, "dynamic", {density=10, friction=1, bounce=0.8, shape=enemies[shape]["vertices"]})

    -- add enemy to table of enemies
    liveEnemies[id] = enemy
end

-- this was used for debugging purposes only
local enemyPlayerTriangles = {}

-- controls behaviour of enemies
local function updateEnemies()
    
    -- DEBUG
    if (debug.drawEnemyPlayerTriangles) then
        for i = 1, #enemyPlayerTriangles, 1 do
            enemyPlayerTriangles[i]:removeSelf()
        end
        enemyPlayerTriangles = {}
    end

    -- go through each enemy
    for id, enemy in next, liveEnemies, nil do

        -- hypot(enuse) is distance from this enemy to the player
        local l = (player.x - enemy.x)
        local h = (player.y - enemy.y)
        local hypot = (math.sqrt(math.pow(l, 2) + math.pow(h, 2)))

        -- DEBUG
        if (debug.drawEnemyPlayerTriangles) then
            table.insert(enemyPlayerTriangles, display.newLine(enemy.x, enemy.y, player.x, player.y, enemy.x, player.y, enemy.x, enemy.y))
        end

        -- want enemies to points towards the player. this angle will do that
        local angle = math.asin(l / hypot);

        -- transition smoothly to the angle - i.e, to face towards the player
        if (h < 0) then
            transition.to(enemy, {time=500, rotation = math.deg(angle)})
        else
            angle = 180 - math.deg(angle)
            transition.to(enemy, {time=500, rotation = angle})
        end

        local speed = enemies[enemy.shape].speed
        -- an enemy's speed is based on how far away they are from the player
        -- l is horizontal component of distance from player to enemy, h is vertical component
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
        
    end
end

local function restorePlayerHealth()
    -- conditional checks to prevent health going above the predefined maximum
    -- function returns true if health increased, else false
    if (state.playerHealth >= maxHealth) then
        return false
    end
    local increaseAmount = math.random(1, 5)
    if (state.playerHealth + increaseAmount <= maxHealth) then
        state.playerHealth = state.playerHealth + increaseAmount
    else
        state.playerHealth = state.playerHealth + (maxHealth - state.playerHealth)
    end
    return true
end

local function restoreAmmo()
    -- conditional checks to prevent ammo going above the predefined maximum
    -- function returns true if ammo increased, else false
    if (state.bullets >= maxAmmo) then 
        return false
    end
    local restoreAmount = math.random(5, 8)
    if (state.bullets + restoreAmount < maxAmmo) then
        state.bullets = state.bullets + restoreAmount
    else
        state.bullets = state.bullets + (maxAmmo - state.bullets)
    end
    return true
end

-- player collision event callback
local function onPlayerCollision(player, e)

    if (e.phase == "began") then

        if (e.other.type == "enemy") then
            -- player-enemy collision
            state.playerHealth = state.playerHealth - enemies[e.other.shape].strength
            audio.play(playerDamageSound);

        else if (e.other.type == "coin") then
            local coin = e.other
            -- player-coin collision
            -- remove the coin
            coin:removeSelf()
            -- each coin has a timer set to remove it after a certain amount of time. need to cancel that timer here otherwise it'll
            -- try and remove a coin that no longer exists as we've already removed it here
            timer.cancel(coinTimers[coin.id])
            table.remove(coinTimers, coin.id)
            audio.play(coinSound)

            -- add to our money balance if player health and ammo are both full
            -- only if restorePlayerHealth returns false (inverted to true), meaning health is full, will the and actually check the next part
            -- i.e., only if health is full will ammo restore. then if both are full, the condition is not(false) and not(false) so money added to balance
            if (not(restorePlayerHealth()) and not(restoreAmmo())) then
                state.money = state.money + 3
            end
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
        -- check if player has enough ammo
        if (state.bullets > 0) then
            -- create bullet
            local bullet = display.newCircle(player.x, player.y, 4);
            bullet:setFillColor(1, 0.16, 0)
            physics.addBody(bullet,"dynamic");
            bullet.isSensor = true
            bullet.type = "bullet"
            bullet.health = state.weapon.bulletHealth
            bullet.fill = bulletTexture
            state.bullets = state.bullets - 1
            -- keep a reference to the movement transition in the bullet itself so we can cancel it
            -- if the bullet hits something (an enemy) before it reaches its destination x and y
            -- and is deleted. else onComplete will try to delete a bullet that no longer exists.
            bullet.transition = transition.to(bullet, {x=e.x, y=e.y, onComplete=deleteBullet})
            audio.play(shootSound)
        end
    end

end

local function removeCoin(e)
    local coin = e.source.params.coin
    coin:removeSelf()
    table.remove(coinTimers, coin.id)
end

local function spawnCoins()

    -- create coin
    local coin = display.newCircle(coins, math.random(0, display.contentWidth), math.random(0, display.contentHeight), 10);
    coin.fill = coinTexture
    coin.alpha = 0.75

    -- coins disappear after a certain length of time if left uncollected. otherwise would be too easy for player
    local expiryTimer = timer.performWithDelay(math.random(1000, 5000), removeCoin, 1, "coinExpiry")
    -- pass the coin as a parameter to its deletion timer to allow easily deletion later on
    expiryTimer.params = {coin=coin}

    local id = os.time()
    coin.type = "coin"
    coin.id = id
    physics.addBody(coin,"dynamic");
    coin.isSensor = true
    coinTimers[id] = expiryTimer

end

local function difficultyControl()
    timer.cancel(spawnEnemiesTimer)
    local elapsedTime = os.time() - beginTime
    state.spawnRate = math.max(2500 - (((os.time() - beginTime)) * 75), 1100)
    spawnEnemiesTimer = timer.performWithDelay(state.spawnRate, spawnEnemy, 0);
end

local function endGame() 
    composer.setVariable("state", state)
	composer.gotoScene("gameOver", {time=800, effect="crossFade"})
end

local function control()
    -- update healthbar
    healthBar.width = math.max(((state.playerHealth / maxHealth) * maxHealthBarWidth), 0)
    -- update ammo bar
    ammo.height = (state.bullets / maxAmmo) * maxAmmoBarHeight
    if state.playerHealth <= 0 and state.stage ~= "dead" then
        state.stage = "dead"
        endGame()
        composer.setVariable("state", state);
    end
    -- health bar turns red if health is low
    if (state.playerHealth < 20) then
        healthBar:setFillColor(1, 0.3, 0.3, 1)
    else 
        healthBar:setFillColor(0.3, 1, 0.42)
    end
    ammoText.text = "Ammo: " .. state.bullets
    -- update money balance
    moneyCounter.text = state.money

    -- difficulty increases as elapsed time increses
    local elapsedTime = os.time() - beginTime
    -- the score just the elpased time
    state.score = elapsedTime
    -- update score counter on screen
    score.text = state.score
    -- as gameplay progresses, the more difficult enemies are added to the table of enemies that can spawn
    if (elapsedTime >= 10 and table.indexOf(spawningEnemies, "pentagon") == nil) then
        table.insert(spawningEnemies,"pentagon")
    elseif (elapsedTime >= 30 and table.indexOf(spawningEnemies, "hexagon") == nil) then
        table.insert(spawningEnemies,"hexagon")
    elseif (elapsedTime >= 60 and table.indexOf(spawningEnemies, "heptagon") == nil) then
        table.insert(spawningEnemies, "heptagon")
    elseif (elapsedTime >= 120 and table.indexOf(spawningEnemies, "octagon") == nil) then
        table.insert(spawningEnemies, "octagon")
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view

	physics.pause()

    -- display groups
    background = display.newGroup()
    sceneGroup:insert(background)
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

    -- game scene background
    backgroundImage = display.newImageRect(background,"game_background.png", display.actualContentWidth, display.actualContentHeight);
    backgroundImage.x = display.contentCenterX
    backgroundImage.y = display.contentCenterY
    backgroundImage.alpha = 0.15

    -- player character
	player = display.newRect(playerGroup, display.contentCenterX, display.contentCenterY, 100, 50);
	player.fill = {255, 255, 255}
	physics.addBody(player,"kinematic",{density=1, friction=1, bounce=0});
	player.isFixedRotation = true

    -- ui
    -- health bar
    healthBarBackground = display.newRect(ui, display.contentCenterX - (maxHealthBarWidth / 2), display.contentHeight - 25, maxHealthBarWidth, 12)
    healthBarBackground:setFillColor(0.65,0.65,0.65)
	healthBar = display.newRect(ui, display.contentCenterX - (maxHealthBarWidth / 2), display.contentHeight - 25, maxHealthBarWidth, 12);
	healthBar:setFillColor(0.3, 1, 0.42)
    healthBar.anchorX = 0
    healthBarBackground.anchorX = 0
    -- ammo
	ammoText = display.newText({parent=ui, text="Ammo: " .. state.bullets, x = 0, y = display.contentHeight - 25, fontSize=12})
    ammo = display.newRect(ui,0,display.contentHeight - 40, 12, maxAmmoBarHeight);
    ammo.anchorY = ammo.height

    -- money
    moneyCounter = display.newText(ui, state.money, display.contentWidth - 50, 20, native.systemFont, 18);
    moneyIndicator = display.newImage(ui,"coin_texture.png",display.contentWidth - 68, 20);
    moneyCounter.anchorX = 0
    moneyIndicator:scale(0.1, 0.1)

    -- score counter
    score = display.newText(ui, "", 0, 20, native.systemFont, 18)

    controlTimer = timer.performWithDelay(10, control, 0)
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
        
        -- add event listeners
		Runtime:addEventListener("key", onKey)
		Runtime:addEventListener("mouse", fireWeapon)
        player.collision = onPlayerCollision
	    player:addEventListener("collision")
		
        -- play background music
        audio.play( music, { channel=1, loops=-1 } )

        -- set timers
		difficultyControlTimer = timer.performWithDelay(5000, difficultyControl, 0)
		spawnCoinsTimer = timer.performWithDelay(1000,spawnCoins,0);
		updateEnemiesTimer = timer.performWithDelay(1000, updateEnemies, 0);
        spawnEnemiesTimer = timer.performWithDelay(state.spawnRate, spawnEnemy, 0);
	
		physics.start()

	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

        -- cancel all game timers
		timer.cancel(spawnCoinsTimer)
        timer.cancel(difficultyControlTimer)
        timer.cancel(updateEnemiesTimer)
        timer.cancel(spawnEnemiesTimer)
		timer.cancel(controlTimer)

        -- remove timers from all coins and all player-movement-related timers
		timer.cancel("coinExpiry")
        timer.cancel("movement")

        -- stop background music
        audio.stop( 1 )

        -- remove event listeners
		Runtime:removeEventListener("key", onKey)
		Runtime:removeEventListener("mouse", fireWeapon)
        player:removeEventListener("collision")

        -- end physics simulation and remove scene
		physics.pause()
		composer.removeScene("game")

	end
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------

return scene
