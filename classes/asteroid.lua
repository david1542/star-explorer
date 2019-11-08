local physics = require('physics')
local constants = require('constants')

local DIRECTIONS = constants.DIRECTIONS
local _M = {}

local originalColor = {
    RED = 0.81,
    GREEN = 0.81,
    BLUE = 0.81,
    ALPHA = 1
}

local fullHp = 100
function _M.newAsteroid(params)
    local randomAsteroidIndex = math.random(3)
    local asteroid = display.newImageRect(params.group, params.sheet, randomAsteroidIndex, 102, 85)

    local healthBar = require('classes.healthbar').newHealthBar({
        group = params.group,
        width = asteroid.width - 20,
        height = 10,
        x = asteroid.x,
        y = asteroid.y 
    })

    asteroid.myName = "asteroid"
    asteroid.hp = fullHp
    asteroid.destroyed = false

    physics.addBody(asteroid, "dynamic", {radius=40, bounce=0.8})

    local whereFrom = math.random(3)
    if (whereFrom == DIRECTIONS.LEFT) then
        -- From the left
        asteroid.x = -60
        asteroid.y = math.random(500)
        asteroid:setLinearVelocity(math.random(40,120), math.random(20,60))
    elseif (whereFrom == DIRECTIONS.TOP) then
        -- From the top
        asteroid.x = math.random( display.contentWidth )
        asteroid.y = -60
        asteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif (whereFrom == DIRECTIONS.RIGHT) then
        -- From the right
        asteroid.x = display.contentWidth + 60
        asteroid.y = math.random( 500 )
        asteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

    -- Returns true if the ship has destroyed
    function asteroid:applyDamage(damage)
        healthBar.show()
        
        self.hp = self.hp - damage

        if self.hp <= 0 then
            self:destroy()
            return true
        end

        self:setFillColor( 1, 0.25, 0.17, 1 )
        transition.to(self.fill, {
            r=originalColor.RED, g=originalColor.GREEN, b=originalColor.BLUE, a=originalColor.ALPHA, time=1000, transition=easing.inCubic
        })
        healthBar.updateHealth(self.hp * 100 / fullHp)
        return false
    end

    function asteroid:updateHealthBarPosition()
        healthBar:updatePosition(self.x, self.y - 55)
    end

    function asteroid:destroy()
        display.remove(self)
        display.remove(healthBar)
    end
    
    asteroid:applyTorque( math.random( -6,6 ) )

    return asteroid
end

return _M