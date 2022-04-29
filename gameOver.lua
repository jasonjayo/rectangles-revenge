local composer = require( "composer" )
local scene = composer.newScene()
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

function scene:create( event )

	local sceneGroup = self.view

	-- get state from game.lua so we can get score info
	local state = composer.getVariable("state");

	-- text informing user they've died
	local title = display.newText(sceneGroup, "You ran out of health. Your final score is", display.contentCenterX, display.contentCenterY - 120, native.systemFont, 14)
	local scoreText = display.newText(sceneGroup, state.score, display.contentCenterX, display.contentCenterY - 60, native.systemFontBold, 75);

	-- play again button
	local playAgainButton = display.newText(sceneGroup, "Play Again", display.contentCenterX - 100, display.contentCenterY + 90, native.systemFont, 14);
	local playAgainButtonBackground = display.newRect(sceneGroup, display.contentCenterX - 100,display.contentCenterY + 90, 100,30);
	playAgainButtonBackground:setFillColor(1,1,1,0.1)
	playAgainButtonBackground:addEventListener("tap", gotoGame)

	-- menu button
	local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX + 100, display.contentCenterY + 90, native.systemFont, 14);
	local menuButtonBackground = display.newRect(sceneGroup, display.contentCenterX + 100, display.contentCenterY + 90, 100,30);
	menuButtonBackground:setFillColor(1,1,1,0.1)
	menuButtonBackground:addEventListener("tap", gotoMenu)

	-- now must update the info saved in the json file
	local storedState = {}

	local filePath = system.pathForFile("storedState.json", system.DocumentsDirectory)
	local file, errorString = io.open( filePath, "r" )

	if file then
		local contents = file:read("*a")
		storedState = json.decode(contents)

		-- store updated money balance
		storedState.money = state.money
		-- check for new high score
		if (storedState.highscore < state.score) then
			display.newText(sceneGroup, "New high score! Congratulations!", display.contentCenterX, display.contentCenterY, native.systemFont, 14);
			-- store new highscore
			storedState.highscore = state.score
		else
			display.newText(sceneGroup, "Thanks for playing.", display.contentCenterX, display.contentCenterY, native.systemFont, 14);
		end
		io.close(file)
	else
		print(errorString)
	end

	file = io.open(filePath, "w")

	-- write updated storedState to file so it can be read next time player comes back
	if file then
		file:write(json.encode(storedState))
		io.close(file)
	end

	-- also update composer variable. initialState is used by game.lua so this needs to be updated in case the user goes straight back
	-- into gameplay using the play again button
	composer.setVariable("initialState", storedState);

end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		composer.removeScene("gameOver")
	end
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------

return scene
