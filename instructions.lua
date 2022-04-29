local composer = require( "composer" )
local scene = composer.newScene()

local function gotoMenu()
	composer.gotoScene("menu", {time=800, effect="crossFade"}); 
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view

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

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
-- -----------------------------------------------------------------------------------

return scene
