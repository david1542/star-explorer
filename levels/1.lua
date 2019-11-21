local TYPES = require('classes.asteroid').TYPES

return {
    waves = {
        {
            delay = 2000,
            asteroids = { TYPES.SMALL, TYPES.SMALL, TYPES.SMALL, TYPES.SMALL, TYPES.SMALL }
        },
        {
            delay = 1000,
            asteroids = { TYPES.HUGE, TYPES.HUGE }
        },
        {
            delay = 1000,
            asteroids = { TYPES.BIG, TYPES.BIG, TYPES.SMALL, TYPES.SMALL }
        },
        {
            delay = 1000,
            asteroids = { TYPES.HUGE, TYPES.BIG, TYPES.BIG }
        }
    }
}