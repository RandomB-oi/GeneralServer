local module = {}
module.__index = module

module.new = function(server, ip, port)
    local self = setmetatable({}, module)
    self.ConnectedServer = server
    self.IP = ip
    self.Port = port

    self.LastRecivedMessage = os.clock()

    self:SendMessage("connected")

    return self
end

function module:SendMessage(message)
    self.ConnectedServer.UDP:sendto(message, self.IP, self.Port)
end

function module:Destroy()
end

return module