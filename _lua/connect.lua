print("starting server")
print(wifi.ap.getip())
ssid = ""
pwd = ""
srv=net.createServer(net.TCP) srv:listen(80,function(conn)
conn:on("receive",function(conn,payload)
print(payload)
if string.find(payload,"favicon.ico") == nil then
if (string.find(payload,"ssid") ~= nil) and (string.find(payload,"pwd") ~= nil) then
payload_len = string.len(payload)
ssid_idx = string.find(payload,"ssid")
pwd_idx = string.find(payload,"pwd=")
amp_idx = string.find(payload,"&")
if amp_idx < pwd_idx then
ssid=string.sub(payload,ssid_idx+5,amp_idx-1)
pwd=string.sub(payload,pwd_idx+4,payload_len)
else
pwd=string.sub(payload,pwd_idx+4,amp_idx-1)
ssid=string.sub(payload,ssid_idx+5,payload_len)
end
print(ssid)
print(pwd)
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid,pwd)
print("Connected to " .. ssid)
file.open("connected","w")
file.close()
node.restart()
end
end
conn:on("sent",function(conn) conn:close() end)
end)
