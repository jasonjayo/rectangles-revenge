----------------------------------------------
-- CS4043 Group 17
-- Rectangle's Revenge
-- Comments and code by Jason Gill (21304092)
----------------------------------------------

local composer = require( "composer" )
local json = require("json")

-- hide status bar
display.setStatusBar(display.HiddenStatusBar)
-- seed random num generator
math.randomseed(os.time())

-- weapon properties
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

-- default game state
local state = {
    money = 0,
    weaponsOwned = {
        "default"
    },
    -- default weapon
    weapon = game.weapons[1],
    highscore = 0
}

-- we want some game state information to persist across playing sessions, namely:
--      equipped weapon
--      owned weapons
--      high score
--      money
-- to facilitate this, this data is stored in a json file on user's computer
-- we'll check for this file now
-- if it exists, game has been played before, so we'll restore their money, owned weapons, high score and currently equipped weapon
-- from last time
-- else we'll use the default state specified in the state variable above and store this in the json file for next time.


local storedState = {}

local filePath = system.pathForFile("storedState.json", system.DocumentsDirectory)
local file, errorString = io.open( filePath, "r" )

	if file then
        -- file found, player has played game before
		local contents = file:read("*a")
		storedState = json.decode(contents)
        
        -- restore state from last time
        state.money = storedState.money
        state.weaponsOwned = storedState.weaponsOwned
        state.weapon = storedState.weapon
        state.highscore = storedState.highscore
		io.close(file)
    else
        -- file not found, player's first time playing
        local file = io.open( filePath, "w")
 
        if file then
            -- store default state in json file
            file:write(json.encode(
                state
            ))
            io.close( file )
        end
    end

-- need to make the state a composer variable so that game.lua and shop.lua can access it later
composer.setVariable("initialState", state)
-- game variable contains weapons info needed by shop.lua
composer.setVariable("game", game)

-- Go to the menu screen
composer.gotoScene( "menu" )