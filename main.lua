local composer = require( "composer" )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )


local game = {
    weapons = {
         {
            -- default
            damage          = { min=1, max=2 },
            cost            = 0,
            description     = "Default",
            name            = "Old Reliable",
            id              = "default"
        },
        {
            
            -- hits up to three times before being destroyed 
            damage          = { min=1, max=2 },
            cost            = 100,
            description     = "Bullets hit up to three times before being destroyed",
            name            = "Ranger",
            id              = "range"
        },
        {
            -- more powerful bullets
            damage          = { min=3, max=5 },
            cost            = 250,
            description     = "The ultimate weapon. Bullets do more damage.",
            name            = "The Ultimate",
            id              = "ultimate"
        },
    }
}

-- persists
local state = {
    money = 500,
    weaponsOwned = {
        "default"
    },
    weapon = {
        id = "default"
    },
    score = 999
}


-- we want some game state information to persist across playing sessions, namely:
--      eqiped weapon
--      owned weapons
--      high score
--      money

local json = require("json")

local storedState = {}



local filePath = system.pathForFile("storedState.json", system.DocumentsDirectory)

local file, errorString = io.open( filePath, "r" )

	if file then
        print("found file")
		local contents = file:read("*a")
		storedState = json.decode(contents)
        
        print("money is " .. storedState.money)


        state.money = storedState.money
        state.weaponsOwned = storedState.weaponsOwned
        state.weapon = storedState.weapon
        state.highscore = storedState.highscore
		io.close(file)
    else
        local file = io.open( filePath, "w")
 
        if file then
            file:write(json.encode(
                {
                    money=state.money,
                    weaponsOwned=state.weaponsOwned,
                    weapon=state.weapon,
                    highscore=0
                }
            ))
            io.close( file )
        end
    end
 
composer.setVariable("initialState", state)
composer.setVariable("game", game)

-- Go to the menu screen
composer.gotoScene( "menu" )