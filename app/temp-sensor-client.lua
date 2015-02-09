require("cord")
temp_sensor = require("temp_sensor")

cport = 49152
csock = storm.net.udpsocket(cport, 
			    function(payload, from, port)
			       print(string.format("echo from %s port %d: %s",from,port,payload))
			    end)

local sensor = temp_sensor:new()

local temperature_monitor = storm.os.invokePeriodically(storm.os.MILLISECOND * 100, function ()
  cord.new(function() 
    local temp = sensor:get()
    local msg = {}
    msg.temp = temp
    local message = storm.mp.pack(msg)
    storm.net.sendto(csock, message, "ff02::1", 7)
  end)
end)

cord.enter_loop()
