
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local state
local moneyCounter
local weapons

local function purchase(e)
	local cost = e.target.weaponCost
	if (state.money >= cost) then
		table.insert(state.weaponsOwned, e.target.weaponId)
		state.money = state.money - cost
		composer.gotoScene("wait", {time=200, effect="crossFade"});
		return true
	end
	return false
end

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

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local backButtonBackground = display.newRect(sceneGroup	,20,29,80,30);
	backButtonBackground:setFillColor(1, 1, 1, 0.1)
	local backButton = display.newText(sceneGroup, "< Back", 20, 30);
	backButtonBackground:addEventListener("tap", gotoMenu)
	

	local title = display.newText(sceneGroup, "SHOP", display.contentCenterX, 40, native.systemFontBold, 40);
	state = composer.getVariable("initialState")
	game = composer.getVariable("game");

	local moneyIndicator
	moneyCounter = display.newText(sceneGroup, state.money, display.contentWidth - 50, 20, native.systemFont, 18);
    moneyIndicator = display.newImage(sceneGroup, "coin_texture.png",display.contentWidth - 68, 20);
    moneyCounter.anchorX = 0
    moneyIndicator:scale(0.1, 0.1)

	local i = -1
	local offset = 120
	for index, weapon in next, game.weapons do
		print(weapon.name)
		local weaponImage = display.newImageRect(sceneGroup, "weapon_" .. weapon.id .. ".png",100, 100)
		weaponImage.x = display.contentCenterX - (i * offset)
		weaponImage.y = display.contentCenterY - 20
		local label = display.newText(sceneGroup, "", display.contentCenterX - (i * offset), display.contentCenterY + 50)
		local description = display.newText(sceneGroup, weapon.description, display.contentCenterX - (i * offset), display.contentCenterY + 160, 100, 200, native.systemFont, 10)
		if (table.indexOf(state.weaponsOwned, weapon.id) == nil) then
			-- don't own weapon
			label.text = weapon.cost .. " coins"
			local buyButton = display.newText(sceneGroup, "Buy", display.contentCenterX - (i * offset), display.contentCenterY + 135);
			local buyButtonBackground = display.newRect(sceneGroup, display.contentCenterX - (i * offset), display.contentCenterY + 135, 80, 30);
			buyButtonBackground:setFillColor(1,1,1,0.1)
			buyButtonBackground.weaponCost = weapon.cost
			buyButtonBackground.weaponId = weapon.id
			buyButtonBackground:addEventListener("tap", purchase)
		else
			-- already own weapon
			label.text = "Already owned"
			if (state.weapon.id ~= weapon.id) then
				local equipButton = display.newText(sceneGroup, "Equip", display.contentCenterX - (i * offset), display.contentCenterY + 135);
				local equipButtonBackground = display.newRect(sceneGroup, display.contentCenterX - (i * offset), display.contentCenterY + 135, 80, 30);
				equipButtonBackground:setFillColor(1,1,1,0.1)
				equipButtonBackground.weapon = weapon
				equipButtonBackground:addEventListener("tap", equipWeapon)
			end
		end
		i=i+1

	end
 
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
		composer.removeScene("shop")

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
