require("cord")
temp_sensor = require("temp_sensor")

cport = 49152
csock = storm.net.udpsocket(cport, 
			    function(payload, from, port)
			       print(string.format("echo from %s port %d: %s",from,port,payload))
			    end)

local sensor = temp_sensor:new()
local last_temp = nil
local temperature_monitor = storm.os.invokePeriodically(storm.os.MILLISECOND * 500, function ()
  cord.new(function() 
    local curr_temp = sensor:get()
    if not last_temp then
       last_temp = curr_temp
    end
    print("last_temp: ", last_temp)
    print("curr_temp: ", curr_temp)
    local difference = last_temp - curr_temp
    if difference < 0 then
       difference = -1 * difference
    end
    print("difference is: ", difference)
    if difference > 4 then
      local msg = {}
      msg.temp = curr_temp
      local message = storm.mp.pack(msg)
      storm.net.sendto(csock, message, "ff02::1", 7)
      last_temp = curr_temp
    end
  end)
end)

cord.enter_loop()
