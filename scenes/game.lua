
local composer = require( "composer" )
local constants = require( "constants" )
local json = require( "json" )
local utils = require( "utils" )
local scene = composer.newScene()

local SCENES = constants.SCENES
local DIRECTORIES = constants.DIRECTORIES
local DIRECTIONS = constants.DIRECTIONS
local IMAGES = constants.IMAGES
local SOUNDS = constants.SOUNDS
local MUSIC = constants.MUSIC
local PARTICLES = constants.PARTICLES
local TRANSITION_TIMES = constants.TRANSITION_TIMES
local TRANSITIONS = constants.TRANSITIONS
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()
physics.setGravity(0, 0)

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}

function loadFile(path)
    local filePath = system.pathForFile(path)
    local f = io.open( filePath, "r" )
    local emitterData = f:read( "*a" )
    f:close()

    return emitterData
end

-- Decode the string
local explosionParams = json.decode(loadFile(PARTICLES.FIRE_EXPLOSION))
local galaxyParams = json.decode(loadFile(PARTICLES.GALAXY))

local objectSheet = graphics.newImageSheet(IMAGES.GAME_OBJECTS, sheetOptions)

-- Initialize variables
local lives = 3
local score = 0
local died = false
local asteroidsTable = {}
 
local ship
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

-- SFX
local explosionSound
local fireSound
local musicTrack
local emitters = {}

local background1
local background2
local scrollSpeed = 3
local runtime = 0

local function addScrollableBackground(group)
    -- Add First bg image
	background1 = display.newImageRect(group, IMAGES.BACKGROUND, display.contentWidth, display.actualContentHeight)
    background1.x = display.contentCenterX
    background1.y = display.contentCenterY
    background1.alpha = 0.6

    background2 = display.newImageRect(group, IMAGES.BACKGROUND, display.contentWidth, display.actualContentHeight)
    background2.x = display.contentCenterX
    background2.y = display.contentCenterY - display.actualContentHeight
    background2.alpha = 0.6
end

local function getDeltaTime()
   local temp = system.getTimer()
   local dt = (temp-runtime) / (1000/60)
   runtime = temp
   return dt
end

local function moveBackground(delta)
    background1.y = background1.y + scrollSpeed * delta
    background2.y = background2.y + scrollSpeed * delta

    if (background1.y - display.contentHeight/2) > display.actualContentHeight then
        background1:translate(0, -background1.contentHeight * 2)
    end
    if (background2.y - display.contentHeight/2) > display.actualContentHeight then
        background2:translate(0, -background2.contentHeight * 2)
    end
end

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function createAsteroid()
    local randomAsteroidIndex = math.random(3)
    local newAsteroid = display.newImageRect(mainGroup, objectSheet, randomAsteroidIndex, 102, 85)
    newAsteroid.myName = "asteroid"
    table.insert(asteroidsTable, newAsteroid)
    physics.addBody(newAsteroid, "dynamic", {radius=40, bounce=0.8})

    local whereFrom = math.random(3)
    if (whereFrom == DIRECTIONS.LEFT) then
        -- From the left
        newAsteroid.x = -60
        newAsteroid.y = math.random(500)
        newAsteroid:setLinearVelocity(math.random(40,120), math.random(20,60))
    elseif (whereFrom == DIRECTIONS.TOP) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif (whereFrom == DIRECTIONS.RIGHT) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

    newAsteroid:applyTorque( math.random( -6,6 ) )
end

local function fireLaser()
    if died then
        return true
    end
     
    audio.play(fireSound)
    local newLaser = display.newImageRect(mainGroup, objectSheet, 5, 14, 40)
    physics.addBody(newLaser, "dynamic", {isSensor=true})
    newLaser.isBullet = true
    newLaser.myName = "laser"

    newLaser.x = ship.x
    newLaser.y = ship.y
    newLaser:toBack()

    transition.to(newLaser, {
        y=-40,
        time=TRANSITION_TIMES.LASER_MOVEMENT,
        onComplete = function() display.remove( newLaser ) end
    })

    return true
end


local function dragShip( event )
    local ship = event.target
    local phase = event.phase
    if (phase == "began") then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
    elseif (phase == "moved") then
        -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffsetX
    elseif ("ended" == phase or "cancelled" == phase) then
        -- Release touch focus on the ship
        display.currentStage:setFocus(nil)
    end

    return true
end

local function moveShip ( event )
    transition.to(ship, {
        x=event.x,
        time=TRANSITION_TIMES.SHIP_MOVEMENT,
        transition=easing.outSine
    })
end

local function restoreShip()
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end

local function gameLoop()
    -- Create new asteroid
    createAsteroid()

    -- Remove asteroids which have drifted off screen
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
 
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
    end
end

local function endGame()
    composer.setVariable( "finalScore", score )
    composer.gotoScene( SCENES.GAME_OVER, TRANSITIONS.PAGE_CHANGE )
end

local function onCollision( event )
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )
            audio.play( explosionSound )

            -- Display an explosion effect
            -- Create the emitter with the decoded parameters
            local emitter = display.newEmitter( explosionParams )
            
            -- Center the emitter within the content area
            emitter.x = obj1.x
            emitter.y = obj1.y
            table.insert(emitters, emitter)

            -- Removing the asteroid from the table
            for i = #asteroidsTable, 1, -1 do
                if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                    table.remove( asteroidsTable, i )
                    break
                end
            end

            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. utils.formatWithCommas(score)
        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
            ( obj1.myName == "asteroid" and obj2.myName == "ship" ) ) then
            if ( died == false ) then
                died = true

                audio.play( explosionSound )
                -- Create the emitter with the decoded parameters
                local emitter = display.newEmitter( explosionParams )
                
                -- Center the emitter within the content area
                emitter.x = obj1.x
                emitter.y = obj1.y
                table.insert(emitters, emitter)
                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives

				if ( lives == 0 ) then
					-- Game over
					display.remove( ship )
					timer.performWithDelay( 2000, endGame )
                else
                    ship.alpha = 0
                    timer.performWithDelay( 1000, restoreShip )
                end
            end
        end
    end
end

function onEnterFrame()
    local delta = getDeltaTime()
    moveBackground(delta)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
    
	physics.pause()  -- Temporarily pause the physics engine

	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

    local emitter = display.newEmitter( galaxyParams )
            
    -- Center the emitter within the content area
    emitter.x = display.contentCenterX
    emitter.y = display.contentCenterY
    emitter.alpha = 0.7
    table.insert(emitters, emitter)

	-- Load the background
    addScrollableBackground(backGroup)

	ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79 )
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100
	physics.addBody( ship, { radius=30, isSensor=true } )
	ship.myName = "ship"

	-- Display lives and score
	livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

	ship:addEventListener( "tap", fireLaser )
	ship:addEventListener( "touch", dragShip )
    backGroup:addEventListener( "tap", function(event)
        moveShip(event)
        timer.performWithDelay(TRANSITION_TIMES.SHIP_MOVEMENT, fireLaser)
    end )

    explosionSound = audio.loadSound( SOUNDS.EXPLOSION )
    fireSound = audio.loadSound( SOUNDS.FIRE )
    musicTrack = audio.loadStream( MUSIC.GAME)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
        Runtime:addEventListener( "enterFrame", onEnterFrame)
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
        
        -- Start the music!
        audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener( "collision", onCollision )
		Runtime:removeEventListener( "enterFrame", onEnterFrame )        
        physics.pause()
        -- Stop the music
        audio.stop( 1 )
		composer.removeScene( SCENES.GAME )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
    -- Dispose audio!
    audio.dispose( explosionSound )
    audio.dispose( fireSound )
    audio.dispose( musicTrack )

    -- Removing all the emitters when the stage is destroyed
    for i = 1, #emitters, 1 do
        emitters[i]:removeSelf()
    end
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
