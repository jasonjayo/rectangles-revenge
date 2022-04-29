local composer = require( "composer" )
local scene = composer.newScene()

local function gotoGame()
    composer.gotoScene( "game", {time=800, effect="crossFade"} )
end
 
local function gotoHelp()
	composer.gotoScene("instructions", {time=800, effect="crossFade"})
end

local function gotoShop()
	composer.gotoScene("shop", {time=800, effect="crossFade"})
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- menu background image
	local background = display.newImage(sceneGroup, "menu_background.png",display.contentCenterX, display.contentCenterY);

	-- game title
	local titleBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight * 0.25, display.actualContentWidth, 75);
	titleBackground:setFillColor(0,0,0,0.85);
	local title = display.newText(sceneGroup, "RECTANGLE'S REVENGE", display.contentCenterX, display.contentHeight * 0.25, native.systemFontBold, 40);

	-- play button
	local playButtonBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 5, 100, 50)
	playButtonBackground:setFillColor(0,0,0,0.65)
	local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, display.contentCenterY + 5, native.systemFont, 25);
	playButtonBackground:addEventListener("tap", gotoGame)

	-- shop button
	local shopButtonBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 70, 100, 50)
	shopButtonBackground:setFillColor(0,0,0,0.65)
	local shopButton = display.newText(sceneGroup, "Shop", display.contentCenterX, display.contentCenterY + 70, native.systemFont, 25);
	shopButtonBackground:addEventListener("tap", gotoShop)

	-- instructions button
	local helpButtonBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 123, 100, 30)
	helpButtonBackground:setFillColor(0,0,0,0.65)
	local helpButton = display.newText(sceneGroup, "Instructions", display.contentCenterX, display.contentCenterY + 123, native.systemFont, 15);
	helpButtonBackground:addEventListener("tap", gotoHelp)

end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
-- -----------------------------------------------------------------------------------

return scene
