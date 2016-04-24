wifi.setmode(wifi.STATIONAP)
cfg={}
cfg.ssid="MOVISTAR_C1EB"
cfg.pwd="8uqH2jjiR6E2PsSfXmvt"
wifi.ap.config(cfg)
print(wifi.ap.getip())

file.remove("connect.lua")
file.open("connect.lua","w")
file.writeline([[print("starting server")]])
file.writeline([[print(wifi.ap.getip())]])
file.writeline([[ssid = ""]])
file.writeline([[pwd = ""]])
file.writeline([[srv=net.createServer(net.TCP) srv:listen(80,function(conn)]])
file.writeline([[conn:on("receive",function(conn,payload)]])
file.writeline([[print(payload)]])



file.writeline([[if string.find(payload,"favicon.ico") == nil then]])
file.writeline([[if (string.find(payload,"ssid") ~= nil) and (string.find(payload,"pwd") ~= nil) then]])

file.writeline([[payload_len = string.len(payload)]])
file.writeline([[ssid_idx = string.find(payload,"ssid")]])
file.writeline([[pwd_idx = string.find(payload,"pwd=")]])
file.writeline([[amp_idx = string.find(payload,"&")]])

file.writeline([[if amp_idx < pwd_idx then]])
file.writeline([[ssid=string.sub(payload,ssid_idx+5,amp_idx-1)]])
file.writeline([[pwd=string.sub(payload,pwd_idx+4,payload_len)]])
file.writeline([[else]])
file.writeline([[pwd=string.sub(payload,pwd_idx+4,amp_idx-1)]])
file.writeline([[ssid=string.sub(payload,ssid_idx+5,payload_len)]])
file.writeline([[end]])

file.writeline([[print(ssid)]])
file.writeline([[print(pwd)]])

file.writeline([[wifi.setmode(wifi.STATION)]])
file.writeline([[wifi.sta.config(ssid,pwd)]])

file.writeline([[print("Connected to " .. ssid)]])

file.writeline([[file.open("connected","w")]])
file.writeline([[file.close()]])
file.writeline([[node.restart()]])

file.writeline([[end]])
file.writeline([[end]])

file.writeline([[html='<html><form method="POST" name="config_wifi"><p>ssid:<input name="ssid" value="" /></p>']])
file.writeline([[html = html .. '<p>pwd:<input name="pwd" value="" /></p>']])
file.writeline([[html = html .. '<p><input type="submit" value="config" /></p>']])
file.writeline([[conn:send( "".. html .." ssid was :" .. ssid .. " pwd was : " .. pwd)]])

file.writeline([[end)]])

file.writeline([[conn:on("sent",function(conn) conn:close() end)]])

file.writeline([[end)]])

file.close()


file.remove("connected.lua")
file.open("connected.lua","w")

file.writeline([[print("starting connected server")]])
file.writeline([[print(wifi.sta.getip())]])
file.writeline([[srv=net.createServer(net.TCP) srv:listen(80,function(conn)]])
file.writeline([[conn:on("receive",function(conn,payload)]])
file.writeline([[print(payload)]])

file.writeline([[if string.find(payload,"favicon.ico") == nil then]])
file.writeline([[end]])

file.writeline([[conn:send("Connected!")]])
file.writeline([[end)]])

file.writeline([[conn:on("sent",function(conn) conn:close() end)]])

file.writeline([[end)]])

file.close()

file.remove("init.lua")
file.open("init.lua","w")

file.writeline([[if file.open("connected","r") == nil then]])
file.writeline([[dofile("connect.lua")]])
file.writeline([[else]])
file.writeline([[dofile("connected.lua")]])
file.writeline([[end]])

file.close()
node.restart()