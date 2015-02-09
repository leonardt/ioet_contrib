require("cord")
cport = 49152

LED = require("led")
brd = LED:new("GP0")

server = function()
   ssock = storm.net.udpsocket(7, 
			       function(payload, from, port)
                                  local message = storm.mp.unpack(paylod)
				  print(string.format("temperature is: ", message.temp))
			       end)
end

server()
