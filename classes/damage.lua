local constants = require('constants')
local _M = {}

local TRANSITION_TIMES = constants.TRANSITION_TIMES

function _M.newDamage(params)
    local damageText = display.newText(params.group, '+' .. params.damage, params.x, params.y, native.systemFont, 36 )
    damageText.alpha = 0;

    transition.to(damageText, {
        alpha = 1,
        time=TRANSITION_TIMES.DAMAGE_FLOATING / 2,
    })
    transition.to(damageText, {
        alpha = 0,
        delay = TRANSITION_TIMES.DAMAGE_FLOATING / 2,
        time=TRANSITION_TIMES.DAMAGE_FLOATING / 2,
    })
    transition.to(damageText, {
        y=params.y-40,
        time=TRANSITION_TIMES.DAMAGE_FLOATING,
        onComplete = function() display.remove( damageText ) end
    })
end

return _M