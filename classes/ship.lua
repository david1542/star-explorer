local physics = require('physics')
local constants = require('constants')
local json = require('json')
local fileUtils = require( "utils.fileUtils" )

local _M = {}

local TRANSITION_TIMES = constants.TRANSITION_TIMES
local PARTICLES = constants.PARTICLES
local SOUNDS = constants.SOUNDS
-- Factory function for creating a ship
-- params should contain group and sheet objects

function _M.newShip(params) 
    local laserSound = audio.loadSound( SOUNDS.FIRE )
    local jetFireParams = json.decode(fileUtils.loadFile(PARTICLES.JET_FIRE))

    local emitter = display.newEmitter( jetFireParams )
    local ship = display.newImageRect(params.group, params.sheet, 4, 98, 79 )
	ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    ship.died = false
    ship.myName = "ship"
    ship.fireDamage = 30
    physics.addBody( ship, { radius=30, isSensor=true } )
    
    -- Center the emitter within the content area
    emitter.x = ship.x
    emitter.y = ship.y + 40
    emitter:scale(0.3, 0.5)
    function ship:fireLaser()
        if self.died then
            return true
        end
         
        audio.play(laserSound)
        local newLaser = display.newImageRect(params.group, params.sheet, 5, 14, 40)
        physics.addBody(newLaser, "dynamic", {isSensor=true})
        newLaser.isBullet = true
        newLaser.myName = "laser"
    
        newLaser.x = self.x
        newLaser.y = self.y
        newLaser:toBack()
    
        transition.to(newLaser, {
            y=-40,
            time=TRANSITION_TIMES.LASER_MOVEMENT,
            onComplete = function() display.remove( newLaser ) end
        })
        return true
    end
    
    
    function ship:dragShip( event )
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
            emitter.x = ship.x
        elseif ("ended" == phase or "cancelled" == phase) then
            -- Release touch focus on the ship
            display.currentStage:setFocus(nil)
        end
    
        return true
    end
    
    function ship:moveShip ( event )
        transition.to(emitter, {
            x=event.x,
            time=TRANSITION_TIMES.SHIP_MOVEMENT,
            transition=easing.outSine
        })
        transition.to(self, {
            x=event.x,
            time=TRANSITION_TIMES.SHIP_MOVEMENT,
            transition=easing.outSine
        })
    end
    
    function ship:restoreShip()
        -- self is the sip
        self.isBodyActive = false
        self.x = display.contentCenterX
        self.y = display.contentHeight - 100

        emitter.x = ship.x
        emitter.y = ship.y + 40
        -- Fade in the ship
        transition.to( emitter, { alpha=1, time=4000 })
        transition.to( self, { alpha=1, time=4000,
            onComplete = function()
                self.isBodyActive = true
                self.died = false
            end
        })
    end

    function ship:kill()
        self.alpha = 0
        emitter.alpha = 0
        timer.performWithDelay( 1000, function()
            self:restoreShip()
        end)
    end
    function ship.dispose()
        display.remove(ship)
        emitter:removeSelf()
        audio.dispose( laserSound )
    end

    ship:addEventListener( "tap", function (event)
        return ship:fireLaser(event)
    end)
    ship:addEventListener( "touch", function (event)
        return ship:dragShip(event)
    end)
    
    return ship
end
return _M