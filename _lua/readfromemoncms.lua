local moduleName = ...
local M = {}
_G[moduleName] = M
local readkey
local channelID

local address = "184.106.153.149" -- IP for api.thingspeak.com

local function loadKeys(fileName)
    if file.open(fileName) then
        local line = file.readline()
        channelID = string.sub(line,1,string.len(line)-1) -- hack to remove CR/LF
        line = file.readline()
        readKey = string.sub(line,1,string.len(line)-1)
        line = file.readline()
        writeKey = string.sub(line,1,string.len(line)-1)
        file.close()
    end
end

function M.setKey(thaKey)
    readKey = thaKey
end

function M.setChannelID(chID)
    channelID = chID
end

function M.setAddr(addr)
    -- for setting an IP address other than thingspeak
    address = addr
end

function M.readData(debug, numResults, callback)
    -- dataToSend is a table of data to send, 
    -- each entry is a table, with names of fields as first value in each entrytable
    -- the second value is the data
    -- if you want to specify exact fields, use fields = true,
    -- and make the third value in each dataToSend table the field number
    -- fileName is name of file containing channelID and API keys and channel ID
    -- callback is a file to run after getting the results
    if wifi.sta.status()~=5 and wifi.sta.status()~=1 then
        wifi.sta.connect()
    end
    if readKey == nil then
        print("The read key hasn't been set yet! Use readTS.setKey('yourAPIreadkey') to set it before reading data.")
        return false
    end
    if channelID == nil then
        print("The channelID hasn't been set yet! Use readTS.setchannelID('yourAPIreadkey') to set it before reading data.")
        return false
    end
    if fields == nil or createdTimes == nil then
        print("You need to create the tables 'fields' and 'createdTimes' first before running.")
    end
    debug = debug or false
    numResults = numResults or 100
    tmr.alarm(1, 1000, 1, function()
        if debug then
            print("connecting")
            print(node.heap())
        end
        if (wifi.sta.status()==5) then
            tmr.stop(1)
            -- timeout incase it can't connect for some reason
            tmr.alarm(1, 5*60*1000, 0, function()
                node.restart()
            end)
            if debug then
                print("connected to wifi")
            end
            sk = net.createConnection(net.TCP, 0)
            sk:on("reconnection", function(conn) 
            if debug then
                print("socket reconnected")
            end
            end)
            sk:on("disconnection", function(conn) 
                if debug then
                    print("socket disconnected")
                end
                if callback~=nil then
                    dofile(callback)
                end
            end)
            sk:on("receive", function(conn, msg)
                if debug then
                    print(msg)
                end
                for i=1, 8, 1 do
                    _, _, fields[i] = string.find(msg, "\"field"..tostring(i).."\":\"(%d*%.?%d*)\"")
                end
                for i=1, numResults, 1 do
                    _, _, createdTimes[i] = string.find(msg, "\"created_at\":\"(%d*%-%d*%-%d*T%d*:%d*:%d*Z)\",\"entry_id\"")
                end
                collectgarbage()
                tmr.stop(1)
                if callback~=nil then
                    dofile(callback)
                end
            end)
            sk:on("connection", function(conn)
                if debug then
                    print("socket connected")
                    print("getting data...")
                    print(node.heap())
                end
                sendStr = "GET /channels/"..channelID.."/feed.json?key="..readKey
                print(node.heap())
                print('numresults: '..tostring(numResults))
                if (numResults~=100) then
                    sendStr = sendStr.."&results="..tostring(numResults)
                end
                print(node.heap())
                sendStr = sendStr.." HTTP/1.1\r\n"
                print(node.heap())
                sendStr = sendStr.."Host: "..address.."\r\n"
                sendStr = sendStr.."Connection: close\r\n"
                sendStr = sendStr.."Accept: */*\r\n"
                sendStr = sendStr.."User-Agent: Mozilla/4.0 (compatible; ESP8266;)\r\n"
                sendStr = sendStr.."\r\n"
                print(node.heap())
                conn:send(sendStr)
                if debug then
                    conn:on("sent", function() print("sent!") end)
                end
                print(sendStr)
            end)
            sk:connect(80, address)
        end
    end)
end

return M