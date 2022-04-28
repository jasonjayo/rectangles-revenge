
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local json = require("json")

local function gotoGame()
    composer.gotoScene( "game", {time=800, effect="crossFade"} )
end

local function gotoMenu()
    composer.gotoScene( "menu", {time=800, effect="crossFade"} )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local state = composer.getVariable("state");

	local title = display.newText(sceneGroup, "You ran out of health. Your final score is", display.contentCenterX, display.contentCenterY - 120, native.systemFont, 14)

	local scoreText = display.newText(sceneGroup, state.score, display.contentCenterX, display.contentCenterY - 60, native.systemFontBold, 75);

	local playAgainButton = display.newText(sceneGroup, "Play Again", display.contentCenterX - 100, display.contentCenterY + 90, native.systemFont, 14);
	local playAgainButtonBackground = display.newRect(sceneGroup, display.contentCenterX - 100,display.contentCenterY + 90, 100,30);
	playAgainButtonBackground:setFillColor(1,1,1,0.1)
	playAgainButtonBackground:addEventListener("tap", gotoGame)

	local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX + 100, display.contentCenterY + 90, native.systemFont, 14);
	local menuButtonBackground = display.newRect(sceneGroup, display.contentCenterX + 100, display.contentCenterY + 90, 100,30);
	menuButtonBackground:setFillColor(1,1,1,0.1)
	menuButtonBackground:addEventListener("tap", gotoMenu)

	local storedState = {}

	local filePath = system.pathForFile("storedState.json", system.DocumentsDirectory)

	local file, errorString = io.open( filePath, "r" )

	if file then
		local contents = file:read("*a")
		storedState = json.decode(contents)

		storedState.money = state.money
		if (storedState.highscore < state.score) then
			print("new high core")
			display.newText(sceneGroup, "New high score! Congratulations!", display.contentCenterX, display.contentCenterY, native.systemFont, 14);

			storedState.highscore = state.score
		else
			display.newText(sceneGroup, "Thanks for playing.", display.contentCenterX, display.contentCenterY, native.systemFont, 14);
		end
		io.close(file)
	else
		print(errorString)
	end

	storedState.money = state.money

	file = io.open(filePath, "w")

	if file then
		file:write(json.encode(storedState))
		io.close(file)
	end

	composer.setVariable("initialState",storedState);

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
		composer.removeScene("gameOver")

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
