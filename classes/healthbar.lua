local _M = {}

-- Creates new healthbar
-- params can contain the following:
-- width, height - size of the health bar
-- x, y

local HEALTH_LEVELS = {
    -- High
    {
        bottom = 66,
        top = 100,
        RED = 0.17,
        GREEN = 0.83,
        BLUE = 0.08
    },
    -- Medium
    {
        bottom = 33,
        top = 66,
        RED = 0.98,
        GREEN = 0.54,
        BLUE = 0.03
    },
    -- Low
    {
        bottom = 0,
        top = 33,
        RED = 0.96,
        GREEN = 0.21,
        BLUE = 0.01
    }
}

function _M.newHealthBar(params)
    local group = display.newGroup()
    local paint = { 1, 1, 1 }
    local container = display.newRect( params.x, params.y, params.width, params.height )
    container.stroke = paint
    container.strokeWidth = 2
    container:setFillColor( 0, 0, 0, 0 )
    
    local colorBar = display.newRect( params.x, params.y, params.width, params.height )
    colorBar:setFillColor( 0.17, 0.83, 0.08 )
    colorBar.anchorX = 0

    group:insert(container)
    group:insert(colorBar)
    group.alpha = 0
    
    function group:updatePosition(x, y)
        container.x = x
        container.y = y

        colorBar.x = x - container.width / 2
        colorBar.y = y
    end

    function group.updateHealth(percent)
        colorBar.width = params.width / 100 * percent

        for _,level in pairs(HEALTH_LEVELS) do
            if level.bottom <= percent and level.top >= percent then
                colorBar:setFillColor(level.RED, level.GREEN, level.BLUE)
                break
            end
        end
    end

    function group:show()
        group.alpha = 1
    end

    return group
end

return _M