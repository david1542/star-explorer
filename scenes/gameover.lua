
local composer = require( "composer" )
local constants = require( "constants" )
local numberUtils = require( "utils.numberUtils" )
local scene = composer.newScene()

local IMAGES = constants.IMAGES
local SCENES = constants.SCENES
local TRANSITIONS = constants.TRANSITIONS
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, IMAGES.BACKGROUND, 800, 1400 )
    background.x = display.contentCenterX
	background.y = display.contentCenterY

    local title = display.newText(sceneGroup, "Game Over", display.contentCenterX, 200, native.systemFont, 60 )
	title:setFillColor( 0.82, 0.86, 1 )
	
	local finalScoreText = display.newText(sceneGroup, "Final Score", display.contentCenterX, 400, native.systemFont, 34 )
	local finalScore = composer.getVariable("finalScore")
	finalScoreText.text = 'Final score: ' .. numberUtils.formatWithCommas(finalScore)

	-- Buttons
	local playButton = display.newText( sceneGroup, "Retry", display.contentCenterX, 700, native.systemFont, 44 )
    playButton:setFillColor( 0.82, 0.86, 1 )
	playButton:addEventListener( "tap", function ()
		composer.gotoScene(SCENES.GAME, TRANSITIONS.PAGE_CHANGE)
	end)

    local menuButton = display.newText( sceneGroup, "Main Menu", display.contentCenterX, 810, native.systemFont, 44 )
	menuButton:setFillColor( 0.75, 0.78, 1 )
	menuButton:addEventListener( "tap", function ()
		composer.gotoScene(SCENES.MENU, TRANSITIONS.PAGE_CHANGE)
	end)
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
