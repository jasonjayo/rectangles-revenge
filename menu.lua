-- CREDIT SCENE TEMPLATE
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()
    composer.gotoScene( "game", {time=800, effect="crossFade"} )
end
 
local function gotoHighScores()
    composer.gotoScene( "highscores", {time=800, effect="crossFade"} )
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

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImage(sceneGroup, "menu_background.png",display.contentCenterX, display.contentCenterY);

	local titleBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight * 0.25, display.actualContentWidth, 75);
	titleBackground:setFillColor(0,0,0,0.85);
	local title = display.newText(sceneGroup, "RECTANGLE'S REVENGE", display.contentCenterX, display.contentHeight * 0.25, native.systemFontBold, 40);

	local playButtonBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 5, 100, 50)
	playButtonBackground:setFillColor(0,0,0,0.65)
	local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, display.contentCenterY + 5, native.systemFont, 25);
	playButtonBackground:addEventListener("tap", gotoGame)
	-- playButton:setFillColor({1,1,1})

	local shopButtonBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 70, 100, 50)
	shopButtonBackground:setFillColor(0,0,0,0.65)
	local shopButton = display.newText(sceneGroup, "Shop", display.contentCenterX, display.contentCenterY + 70, native.systemFont, 25);
	shopButtonBackground:addEventListener("tap", gotoShop)

	local helpButtonBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 123, 100, 30)
	helpButtonBackground:setFillColor(0,0,0,0.65)
	local helpButton = display.newText(sceneGroup, "Instructions", display.contentCenterX, display.contentCenterY + 123, native.systemFont, 15);
	helpButtonBackground:addEventListener("tap", gotoHelp)

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
