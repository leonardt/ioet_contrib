require("cord")
cport = 49152
local discovery_port = 1525

csock = storm.net.udpsocket(cport, 
			    function(payload, from, port)
			    end)

local svc_manifest = {id="HW-Defined-SW", getNow={ s="getNumber", desc="echotime"}}

local msg = storm.mp.pack(svc_manifest)
storm.os.invokePeriodically(5*storm.os.SECOND, function()
                            storm.net.sendto(csock, msg, "ff02::1", discovery_pot)
end)


local services = {}
local devices = {}

function discover_handler(payload, from, port)
  local message = storm.mp.unpack(payload)
  devices[message.id] = {ip=from, 
                         port=port, 
                         last_ping=storm.os.now(storm.os.SHIFT_0)}
  for k,v in pairs(message) do
     if k ~= "id" then
        if services[k] == nil then
           local d = {}
           d[message.id] = devices[message.id]
           services[k] = {s=v.s, desc=v.desc, devices=d}
        else
           table.insert(services[k].devices, message.id)
           if services[k].devices[message.id] == nil then
              services[k].devices[message.id] = devices[message.id]
           end
        end
     end
  end
  print(string.format("discovered %s ip: %s port %d", message.id, from, port))
  print("------------------")
  print("Available services")
  for k,v in pairs(services) do
     print("service: ", k)
     print("devices:")
     for k,v in pairs(devices) do
        print(k)
     end
  end
  print("------------------")
end

server_sock = storm.net.udpsocket(discovery_port, discovery_handler)

local service_port = 1526
function service_handler(payload, from, port)
   local message = storm.mp.unpack(payload)
   if message[0] == "getNow" then
      local response = {}
      local echotime = message[1]
      response[0] = storm.os.getNow(storm.os.SHIFT_16)
      response[1] = message[1]
      local resp = storm.mp.pack(response)
      storm.net.sendto(service_sock, resp, from, port) 
   end
end

service_sock = storm.net.updsocket(service_port, service_handler)

sh = require "stormsh"
sh.start()
cord.enter_loop() -- start event/sleep loop
