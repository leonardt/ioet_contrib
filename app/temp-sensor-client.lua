require("cord")

cport = 49152
csock = storm.net.udpsocket(cport, 
			    function(payload, from, port)
			       print(string.format("echo from %s port %d: %s",from,port,payload))
			    end)

local temperature_monitor = storm.os.invokePeriodically(storm.os.MILLISECOND * 10, function ()
  local temp = temp_sensor.get_temp()
  local message = storm.mp.pack(temp)
  storm.net.sendto(csock, message, "ff02::1", 7)
end)

cord.enter_loop()
