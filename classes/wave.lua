local constants = require('constants')
local Asteroid = require('classes.asteroid')
local IMAGES = constants.IMAGES
local DIRECTORIES = constants.DIRECTORIES
local sheetOptions = require(DIRECTORIES.SHEETS .. 'general')

local _M = {}

-- Creates a new wave
-- wave param needs to be a list which contains array of asteroid types

local objectSheet = graphics.newImageSheet(IMAGES.GAME_OBJECTS, sheetOptions)

function _M.newWave(wave, context)
    local waveGroup = display.newGroup()
    local asteroidsTable = {}
    local spawnedAsteroidIndex = 0
    waveGroup.initiated = false
    function waveGroup:initiate()
        waveGroup.initiated = true
        timer.performWithDelay(wave.delay, function()
            -- Incrementing the index for the next asteroid
            spawnedAsteroidIndex = spawnedAsteroidIndex + 1
            
            local asteroidType = wave.asteroids[spawnedAsteroidIndex]
            spawnAsteroid(asteroidType)
        end, #wave.asteroids)
    end

    function spawnAsteroid(type)
        local asteroid = Asteroid.newAsteroid({
            group = waveGroup,
            sheet = objectSheet,
            type = type
        })
        table.insert(asteroidsTable, asteroid)
    end

    function waveGroup:performCheck()
        for i = #asteroidsTable, 1, -1 do
            local thisAsteroid = asteroidsTable[i]
     
            if ( thisAsteroid.x < -100 or
                 thisAsteroid.x > display.contentWidth + 100 or
                 thisAsteroid.y < -100 or
                 thisAsteroid.y > display.contentHeight + 100 )
            then
                thisAsteroid:destroy()
                table.remove( asteroidsTable, i )
            end
        end
    end

    function waveGroup.isWaveEnded()
        return spawnedAsteroidIndex == #wave.asteroids and not next(asteroidsTable)
    end

    function waveGroup:applyDamage(asteroid, damage)
        for i = #asteroidsTable, 1, -1 do
            if ( asteroidsTable[i] == asteroid ) then
                local destroyed = asteroid:applyDamage(damage)
                
                if destroyed then
                    table.remove( asteroidsTable, i )
                    self.onDestroy(asteroid.points)
                end
                break
            end
        end
    end

    function waveGroup:update()
        for i = #asteroidsTable, 1, -1 do
            local asteroid = asteroidsTable[i]
            asteroid:updateHealthBarPosition()
        end
    end

    function waveGroup:onDestroy(listener)
        self.onDestroy = listener
    end

    return waveGroup
end
return _M