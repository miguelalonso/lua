wifi.setmode(wifi.STATION);
wifi.sta.config("MOVISTAR_C1EB","8uqH2jjiR6E2PsSfXmvt");
 
function postThingSpeak(level)
print(wifi.sta.getip())
    connout = nil
    connout = net.createConnection(net.TCP, 0)
 
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
 
    connout:on("connection", function(connout, payloadout)
 
        print ("Posting...");
 
        local volt = node.readvdd33();  
        local volta0 = adc.read(0);
            
        print ((volta0/1000) .. "." .. (volta0%1000));
        print ("Internal volatage:");
        print ((volt/1000) .. "." .. (volt%1000));
 
        connout:send("GET /emoncms_spectrum/input/post.json?json={analog:" 
        .. (volta0/1000) .. "." .. (volta0%1000)
        ..",intvolt:"..(volt/1000) .. "." .. (volt%1000)
        .."}&apikey=7953d32569acd2a5384adf18f0a837f3"
        .. " HTTP/1.1\r\n"
        .. "Host: 163.117.157.189\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
 
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        collectgarbage();
    end)
 --163.117.157.189/emoncms_spectrum/input/post.json?json={power:200}
    connout:connect(80,'163.117.157.189')
end
 
tmr.alarm(1, 60000, 1, function() postThingSpeak(0) end)