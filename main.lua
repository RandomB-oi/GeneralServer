local ServerClass = require("Server")

local newServer

function love.load()
    love.window.setTitle("Server")
    love.window.setMode(300, 200, {resizable = true})

    newServer = ServerClass.new(8080, 1/5)


    function love.update()
        newServer:Tick()
    end
    
    local lineHeight = 16
    
    local msgCount = 0
    local function resetMsgs()
        msgCount = 0
    end
    local function msg(text, maxWidth)
        love.graphics.printf(text, 0, lineHeight*msgCount, maxWidth or 500)
        msgCount = msgCount+1
    end
    
    function love.draw()
        resetMsgs()
        msg("Server Window: port:"..tostring(newServer.Port))
        msg("Last Message: "..tostring(newServer.LastMessage), math.huge)
        msg("Active Connections:")
    
        for id in pairs(newServer.ConnectedClients) do
            msg("\t"..id)
        end
    end
end