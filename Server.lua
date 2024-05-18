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
    self.LastMessageTime = os.clock()

    return self
end

function module:Tick()
    local data, msgOrIp, portOrNil = self.UDP:receivefrom()
    if msgOrIp == "timeout" then return end -- no message
    
    -- print(data)
    -- print(msgOrIp, portOrNil)
    -- print("--------")
    if msgOrIp and portOrNil then
        local client = self.ConnectedClients[msgOrIp]
        if not client then
            client = ClientClass.new(self, msgOrIp, portOrNil)
            self.ConnectedClients[msgOrIp] = client
        end

        self.LastMessage = data
        self.LastMessageTime = os.clock()

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

local lineHeight = 16

local msgCount = 0
local function resetMsgs()
    msgCount = 0
end
local function msg(text, maxWidth)
    love.graphics.printf(text, 0, lineHeight*msgCount, maxWidth or 500)
    msgCount = msgCount+1
end


function module:DrawInfo()
    resetMsgs()
    msg("Server Window: port:"..tostring(self.Port))
    local timeResolution = 10
    msg("Time Since Last Message: "..tostring(math.floor((os.clock() - self.LastMessageTime)*timeResolution)/timeResolution), math.huge)
    msg("Active Connections:")

    for id in pairs(self.ConnectedClients) do
        msg("\t"..id)
    end
end

function module:Destroy()
    for ip, client in pairs(self.ConnectedClients) do
        self:RemoveClient(ip)
    end
end

return module