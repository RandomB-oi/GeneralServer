local ServerClass = require("Server")

local newServer

function love.load()
    love.window.setTitle("Server")
    love.window.setMode(300, 200, {resizable = true})

    newServer = ServerClass.new(8080, 0)


    function love.update()
        newServer:Tick()
    end

    function love.draw()
        newServer:DrawInfo()
    end
end