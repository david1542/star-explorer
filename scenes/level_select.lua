
local composer = require( "composer" )
local constants = require('constants')
local widget = require('widget')

local DIRECTORIES = constants.DIRECTORIES
local TRANSITIONS = constants.TRANSITIONS
local IMAGES = constants.IMAGES
local scene = composer.newScene()

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
    local group = self.view

    -- local background = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    local background = display.newImageRect(group, IMAGES.BACKGROUND, display.contentWidth, display.actualContentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)
    
    local title = display.newText(sceneGroup, "Choose Level", display.contentCenterX, 150, native.systemFont, 60 )
    title:setFillColor( 0.82, 0.86, 1 )
    sceneGroup:insert(title)

	local visualButtons = {}
	local buttonsGroup = display.newGroup()
	buttonsGroup.x, buttonsGroup.y = 0, 0
	sceneGroup:insert(buttonsGroup)

    local function onLevelButtonRelease(event)
		composer.gotoScene('scenes.game', {
            time=800,
            effect="crossFade",
            params = {
                level = event.target.id
            }
        })
	end

	-- Button positioning is grid based, x,y are grid points
    local x, y = 1, 0
    local startingY = 200
    local spacing = 130
    local buttonWidth = 90
    local buttonHeight = 100
    local buttonsPerRow = math.ceil(display.contentWidth / (buttonWidth + spacing))
    local buttonsGroupLimit = buttonsPerRow > 4 and 4 or buttonsPerRow

	for i = 1, composer.getVariable('levelCount') do
		local button = widget.newButton({
			id = i,
			label = i,
			labelColor = {default = {1}, over = {0.5}},
			font = native.systemFontBold,
			fontSize = 50,
			labelYOffset = -7,
			defaultFile = DIRECTORIES.IMAGES .. 'buttons/level.png',    
			overFile = DIRECTORIES.IMAGES .. 'buttons/level-over.png',
			width = buttonWidth, height = buttonHeight,
			x = x * spacing + (buttonWidth / 2) + 13, y = startingY + 32 + y * spacing + 87,
			onRelease = onLevelButtonRelease
		})
		buttonsGroup:insert(button)
		table.insert(visualButtons, button)

        x = x + 1
		if i % buttonsPerRow == 0 then
			x = 1
			y = y + 1
		end
		-- Check if this level was completed
		-- if databox['level' .. i] then
		-- 	local check = display.newImageRect(DIRECTORIES.IMAGE .. 'check.png', 48, 48)
		-- 	check.anchorX, check.anchorY = 1, 1
		-- 	check.x, check.y = button.width - 3, button.height - 18
		-- 	button:insert(check) -- Insert after positioning, because if inserted before, button.width/height will be different
		-- end
    end
    
    self.gotoPreviousScene = 'scenes.menu' -- Allow going back on back button press
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
