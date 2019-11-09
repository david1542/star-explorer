local _M = {}

function loadFile(path)
    local filePath = system.pathForFile(path)
    local f = io.open( filePath, "r" )
    local emitterData = f:read( "*a" )
    f:close()

    return emitterData
end

_M.loadFile = loadFile
return _M