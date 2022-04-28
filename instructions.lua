
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
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

	local title = display.newText(sceneGroup, "INSTRUCTIONS", display.contentCenterX, 30, native.systemFontBold, 35);

	local instructionText = [[The polygons are your enemies! Your goal is to survive as long as you can. 
	You must kill them using your weapon.

	Controls:
	- To fire your weapon, left click.
	- To move, use the arrow keys.
	- Coins are picked up by passing over them. They give you a health boost, then some ammo.
	        - If you already have max health and max ammo, they'll increase your coin balance!
	- The game gets progressively harder the longer you last as more challenging enemies spawn.

	Shop:
	- You can use your coin balance to buy weapon upgrades or apply one you already own.

	The more sides an enemy has, the stronger it is! 
	]]
	
	local instructionsBody = display.newText(sceneGroup, instructionText, display.contentCenterX, display.contentCenterY * 1.3, display.contentWidth, display.contentHeight * 0.9, native.systemFont, 11)

	local backButtonBackground = display.newRect(sceneGroup	,20,29,80,30);
	backButtonBackground:setFillColor(1, 1, 1, 0.1)
	local backButton = display.newText(sceneGroup, "< Back", 20, 30, native.systemFont, 14);
	backButtonBackground:addEventListener("tap", gotoMenu)

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
