require("cord")
cport = 49152

LED = require("led")
brd = LED:new("GP0")

server = function()
   ssock = storm.net.udpsocket(7, 
			       function(payload, from, port)
				  print(string.format("from %s port %d: %s",from,port,payload))
                                  local message = storm.mp.unpack(paylod)
				  brd:flash(1)
			       end)
end

server()
