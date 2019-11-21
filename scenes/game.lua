
local composer = require( "composer" )
local constants = require( "constants" )
local json = require( "json" )
local numberUtils = require( "utils.numberUtils" )
local fileUtils = require( "utils.fileUtils" )
local Asteroid = require('classes.asteroid')
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

-- Decode the string
local explosionParams = json.decode(fileUtils.loadFile(PARTICLES.FIRE_EXPLOSION))
local confettiParams = json.decode(fileUtils.loadFile(PARTICLES.CONFETTI))
local sheetOptions = require(DIRECTORIES.SHEETS .. 'general')
local objectSheet = graphics.newImageSheet(IMAGES.GAME_OBJECTS, sheetOptions)
-- Initialize variables
local lives = 3
local score = 0

local levelData
local currentWaveIndex = 1
local currentWave
local ship
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

-- SFX
local explosionSound
local musicTrack
local emitters = {}

local background1
local background2
local scrollSpeed = 4
local runtime = 0

local function addScrollableBackground(group)
    -- Add First bg image
	background1 = display.newImageRect(group, IMAGES.BACKGROUND, display.contentWidth, display.actualContentHeight)
    background1.x = display.contentCenterX
    background1.y = display.contentCenterY
    background1.alpha = 0.7

    background2 = display.newImageRect(group, IMAGES.BACKGROUND, display.contentWidth, display.actualContentHeight)
    background2.x = display.contentCenterX
    background2.y = display.contentCenterY - display.actualContentHeight
    background2.alpha = 0.7
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

local function endGame()
    ship.dispose()
    timer.performWithDelay( 2000, function()
        composer.setVariable( "finalScore", score )
        composer.gotoScene( SCENES.GAME_OVER, TRANSITIONS.PAGE_CHANGE )
    end)
end

local function showConfetti()
    local emitter = display.newEmitter( confettiParams )
            
    -- Center the emitter within the content area
    emitter.x = display.contentCenterX
    emitter.y = display.contentCenterY
    table.insert(emitters, emitter)
end

local function updateScore(points)
    -- Increase score
    score = score + points
    scoreText.text = "Score: " .. numberUtils.formatWithCommas(score)
    local duration = 500
    transition.to(scoreText.fill, {
        r=0.95, g=0.92, b=0.04, a=1, time=duration
    })
    transition.to(scoreText, {
        xScale = 1.3,
        yScale = 1.3,
        time=duration
    })
    transition.to(scoreText, {
        xScale = 1,
        yScale = 1,
        time=duration,
        delay=duration
    })
    transition.to(scoreText.fill, {
        r=1, g=1, b=1, a=1, time=duration, delay=duration
    })
end


local function initiateWave(data)
    local newWave = require('classes.wave').newWave(data)
    newWave:onDestroy(updateScore)

    return newWave
end

local function gameLoop()
    if currentWave then
        if not currentWave.initiated then
            currentWave:initiate()
        end
    
        currentWave:performCheck()
        if (currentWave.isWaveEnded()) then
            showConfetti()

            -- Moving to the next wave
            currentWaveIndex = currentWaveIndex + 1
            currentWave = initiateWave(levelData.waves[currentWaveIndex])
        end
    end
end

local function onCollision( event )
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            local asteroid
            local laser
            if (obj1.myName == 'laser') then
                laser = obj1
                asteroid = obj2
            else
                laser = obj2
                asteroid = obj1
            end

            display.remove( laser )
            audio.play( explosionSound )
            -- Display an explosion effect
            -- Create the emitter with the decoded parameters
            local emitter = display.newEmitter( explosionParams )
            
            -- Center the emitter within the content area
            emitter.x = asteroid.x
            emitter.y = asteroid.y
            table.insert(emitters, emitter)

            -- Display damage label
            local damageLabel = require('classes.damage').newDamage({
                group = mainGroup,
                damage = 30,
                x = asteroid.x,
                y = asteroid.y
            })
            -- Removing the asteroid from the table
            currentWave:applyDamage(asteroid, ship.fireDamage)
        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
            ( obj1.myName == "asteroid" and obj2.myName == "ship" ) ) then
            if ( ship.died == false ) then
                ship.died = true

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
                    endGame()
                else
                    ship:kill()
                end
            end
        end
    end
end

function onEnterFrame()
    local delta = getDeltaTime()
    moveBackground(delta)

    if currentWave then
        currentWave:update()
    end
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

    levelData = require('levels.' .. event.params.level)
    currentWave = initiateWave(levelData.waves[currentWaveIndex])

    mainGroup:insert(currentWave)
	-- Load the background
    addScrollableBackground(backGroup)

    ship = require('classes.ship').newShip({
        group = mainGroup,
        sheet = objectSheet
    })
	-- Display lives and score
	livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

    backGroup:addEventListener( "tap", function(event)
        ship:moveShip(event)
        timer.performWithDelay(TRANSITION_TIMES.SHIP_MOVEMENT, function()
            ship:fireLaser()
        end)
    end )

    explosionSound = audio.loadSound( SOUNDS.EXPLOSION )
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
