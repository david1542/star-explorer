	
local composer = require( "composer" )
local constants = require( "constants" )

local SCENES = constants.SCENES
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )
 
-- Go to the menu screen
composer.setVariable('levelCount', 1)
composer.gotoScene( SCENES.MENU )
-- Reserve channel 1 for background music
audio.reserveChannels( 1 )
-- Reduce the overall volume of the channel
audio.setVolume( 0.5, { channel=1 } )