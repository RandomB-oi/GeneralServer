local module = {}
module.__index = module

local SocketModule = require("socket")
local ClientClass = require("ConnectedClient")

module.new = function(port, maxtimeout)
    local self = setmetatable({}, module)
    
    self.Port = port

    self.UDP = SocketModule.udp()
    self.UDP:setsockname("localhost", port)
    self.UDP:settimeout(maxtimeout or 0)

    self.ConnectedClients = {}
    self.ClientTimeoutLength = 5

    self.LastMessage = ""

    return self
end

function module:Tick()
    local data, msgOrIp, portOrNil = self.UDP:receivefrom()
    if data then
        local client = self.ConnectedClients[msgOrIp]
        if not client then
            client = ClientClass.new(self, msgOrIp, portOrNil)
            self.ConnectedClients[msgOrIp] = client
        end

        self.LastMessage = data
        client.LastRecivedMessage = os.clock()
        client:SendMessage("gotData")

        for ip, otherClient in pairs(self.ConnectedClients) do
            if ip ~= msgOrIp then
                otherClient:SendMessage(data)
            end
        end
    end

    self:CleanClients()
end

function module:RemoveClient(ip)
    if not self.ConnectedClients[ip] then return end

    self.ConnectedClients[ip]:Destroy()
    self.ConnectedClients[ip] = nil
end

function module:CleanClients()
    for ip, client in pairs(self.ConnectedClients) do
        if os.clock() - client.LastRecivedMessage > self.ClientTimeoutLength then
            self:RemoveClient(ip)
        end
    end 
end

function module:Destroy()
    for ip, client in pairs(self.ConnectedClients) do
        self:RemoveClient(ip)
    end
end

return module