require("cord")
MoodyLED = require("moodyled");


blue_led = MoodyLED:new{pin = "D2"}

-- blue_led:print_behaviors()

storm.os.invokePeriodically(14000 * storm.os.MILLISECOND, function()
	s = cord.new(function()
			for i, b in pairs(blue_led.behaviors) do 
				print("   ", i)
				blue_led:play_behavior(i, 2000)
				cord.await(storm.os.invokeLater, 2100 * storm.os.MILLISECOND)
			end
	end)
end)

-- blue_led:flash(20)


cord.enter_loop()


cport = 49152



server = function()
   ssock = storm.net.udpsocket(7, 
			       function(payload, from, port)
                        local message = storm.mp.unpack(payload)
				  		print(string.format("Temperature is: %d", message.temp))
				  		brd:flash() -- show that the message has been received
			       end)
end

server()

cord.enter_loop()