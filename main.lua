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
            id              = "default",
            bulletHealth    = 1
        },
        {
            
            -- hits up to three times before being destroyed 
            damage          = { min=1, max=2 },
            cost            = 25,
            description     = "Bullets hit up to three times before being destroyed.",
            name            = "Ranger",
            id              = "range",
            bulletHealth    = 3
        },
        {
            -- more powerful bullets
            damage          = { min=3, max=5 },
            cost            = 50,
            description     = "The ultimate weapon. Bullets do more damage.",
            name            = "The Ultimate",
            id              = "ultimate",
            bulletHealth    = 1
        },
    }
}

-- persists
local state = {
    money = 0,
    weaponsOwned = {
        "default"
    },
    weapon = game.weapons[1],
    highscore = 0
}

-- local test = {info= {a= "This is test 1"}}
-- composer.setVariable("test", test);
-- test = {info= {a="This is test 2"}}
-- composer.setVariable("test", test);

-- print(composer.getVariable("test").info.a)


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
		local contents = file:read("*a")
		storedState = json.decode(contents)
        


        state.money = storedState.money
        state.weaponsOwned = storedState.weaponsOwned
        state.weapon = storedState.weapon
        state.highscore = storedState.highscore
		io.close(file)
    else
        local file = io.open( filePath, "w")
 
        if file then
            file:write(json.encode(
                state
            ))
            io.close( file )
        end
    end
 
composer.setVariable("initialState", state)
composer.setVariable("game", game)

-- Go to the menu screen
composer.gotoScene( "menu" )