local composer = require( "composer" )
local json = require("json")
local scene = composer.newScene()

local state
local moneyCounter
local weapons
local notEnoughMoney


-- buy weapon
local function purchase(e)
	local cost = e.target.weaponCost
	if (state.money >= cost) then
		-- can afford
		table.insert(state.weaponsOwned, e.target.weaponId)
		state.money = state.money - cost
		composer.gotoScene("wait", {time=200, effect="crossFade"});
		return true
	else
		-- cannot afford, flash red around our money balace on screen to indicate this to player
		notEnoughMoney.alpha = 1
		local notEnoughMoneyFlash = transition.blink(notEnoughMoney, {time=750})
		timer.performWithDelay(1000,function() 
			transition.cancel(notEnoughMoneyFlash) 
			notEnoughMoney.alpha = 0
		end,1);
	end
	return false
end

-- the wait scene sends us back here, but this scene will fully reload so all data is fresh. the crossFade makes the transition smooth
-- so user doesn't notice any scene change, just updated info 
local function equipWeapon(e)
	state.weapon = e.target.weapon
	composer.gotoScene("wait", {time=200, effect="crossFade"});
end

local function gotoMenu()
	composer.gotoScene("menu", {time=800, effect="crossFade"}); 
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- back button
	local backButtonBackground = display.newRect(sceneGroup	,20,29,80,30);
	backButtonBackground:setFillColor(1, 1, 1, 0.1)
	local backButton = display.newText(sceneGroup, "< Back", 20, 30, native.systemFont, 14);
	backButtonBackground:addEventListener("tap", gotoMenu)
	
	-- title
	local title = display.newText(sceneGroup, "SHOP", display.contentCenterX, 40, native.systemFontBold, 40);

	-- state contains info about player like their money
	state = composer.getVariable("initialState")
	-- game variable contains info about the weapons
	game = composer.getVariable("game");

	-- used to indicate that player does not have enough money for a purchase
	notEnoughMoney = display.newRect(sceneGroup,display.contentWidth - 50, 19, 100, 20);
	notEnoughMoney.alpha = 0
	notEnoughMoney:setFillColor(1,0,0)

	-- moeny count and indicator
	local moneyIndicator
	moneyCounter = display.newText(sceneGroup, state.money, display.contentWidth - 50, 20, native.systemFont, 18);
    moneyIndicator = display.newImage(sceneGroup, "coin_texture.png",display.contentWidth - 68, 20);
    moneyCounter.anchorX = 0
    moneyIndicator:scale(0.1, 0.1)
	
	--  go through each weapon and display it
	local i = -1
	-- offset used for x positioning
	local offset = 120
	for index, weapon in next, game.weapons do
		-- weapon image
		local weaponImage = display.newImageRect(sceneGroup, "weapon_" .. weapon.id .. ".png",100, 100)
		weaponImage.x = display.contentCenterX - (i * offset)
		weaponImage.y = display.contentCenterY - 40
		-- weapon details
		local name = display.newText(sceneGroup, weapon.name, display.contentCenterX - (i * offset), display.contentCenterY + 20, native.systemFont, 14)
		local label = display.newText(sceneGroup, "", display.contentCenterX - (i * offset), display.contentCenterY + 105, native.systemFont, 14)
		local description = display.newText(sceneGroup, weapon.description, display.contentCenterX - (i * offset), display.contentCenterY + 145, 100, 200, native.systemFont, 10)
		
		if (table.indexOf(state.weaponsOwned, weapon.id) == nil) then
			-- don't own weapon
			-- display cost and buy button
			label.text = weapon.cost .. " coins"
			local buyButton = display.newText(sceneGroup, "Buy", display.contentCenterX - (i * offset), display.contentCenterY + 135, native.systemFont, 14);
			local buyButtonBackground = display.newRect(sceneGroup, display.contentCenterX - (i * offset), display.contentCenterY + 135, 80, 30);
			buyButtonBackground:setFillColor(1,1,1,0.1)
			buyButtonBackground.weaponCost = weapon.cost
			buyButtonBackground.weaponId = weapon.id
			buyButtonBackground:addEventListener("tap", purchase)
		else
			-- already own weapon
			if (state.weapon.id ~= weapon.id) then
				-- the weapon is owned but not currently equipped
				label.text = "Already owned"
				local equipButton = display.newText(sceneGroup, "Equip", display.contentCenterX - (i * offset), display.contentCenterY + 135, native.systemFont, 14);
				local equipButtonBackground = display.newRect(sceneGroup, display.contentCenterX - (i * offset), display.contentCenterY + 135, 80, 30);
				equipButtonBackground:setFillColor(1,1,1,0.1)
				equipButtonBackground.weapon = weapon
				equipButtonBackground:addEventListener("tap", equipWeapon)
			else
				-- the weapon is owned and already equipped
				label.text = "Already owned, \ncurrently equipped"
			end
		end
		i=i+1
	end
 
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		-- when moving away from this scene, we need to update the state as we may have bought a new weapon, in which case
		-- our money and owned weapons list will have changed. our equipped weapon may also have changed 
		composer.setVariable("state",state);
		-- we also need to update the info in the json file so if we leave the game and come back later we still have the weapon
		-- we may have just bought!
		local filePath = system.pathForFile("storedState.json", system.DocumentsDirectory)
		file = io.open(filePath, "w")

		if file then
			file:write(json.encode(state))
			io.close(file)
		end	

		composer.removeScene("shop")
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------

return scene
