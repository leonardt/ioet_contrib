require("cord")
MoodyLED = require("MoodyLED")

-- initialize LEDs
local blue_led = MoodyLED:new{ pin = "D2"}
local green_led = MoodyLED:new{ pin = "D3"}
local red_led = MoodyLED:new{ pin = "D4"}
local red2_led = MoodyLED:new{ pin = "D5"}

cport = 49152

function HOT()
	red_led:play_behavior("blink_increasing", 2000)
	red2_led:play_behavior("blink_increasing", 2000)
end

function WARM()
	red_led:play_behavior("blink_increasing", 2000)
end

function CHILLY()
	blue_led:play_behavior("blink_decreasing", 4000)
end

function COOL()
	blue_led:play_behavior("blink_decreasing", 2000)
end

function HARMONY()
	blue_led:play_behavior("heartbeat", 1000)
	red_led:play_behavior("heartbeat", 1000)
	red2_led:play_behavior("heartbeat", 1000)
end


function STARTUP()
	s = cord.new(function()
		blue_led:play_behavior("sos", 2000)
		cord.await(storm.os.invokeLater, 2000 * storm.os.MILLISECOND)
		green_led:play_behavior("sos", 2000)
		cord.await(storm.os.invokeLater, 2000 * storm.os.MILLISECOND)
		red_led:play_behavior("sos", 2000)
		cord.await(storm.os.invokeLater, 2000 * storm.os.MILLISECOND)
		red2_led:play_behavior("sos", 2000)
	end)
end

server = function()
   ssock = storm.net.udpsocket(10, 
			       function(payload, from, port)
                        local message = storm.mp.unpack(payload)
				  		print(string.format("Temperature is: %d", message.temp))
				  		print(string.format("Difference is: %d", message.diff))

				  		green_led:play_behavior("transmission_fixed_brightness", 1000) -- show that the message has been received

				  		if message.diff < -8 then 
				  			-- REALLY HOT
				  			HOT()
				  		elseif message.diff <= - 4 then 
				  			-- WARM
				  			WARM()
				  		elseif message.diff > 8 then 
				  			-- CHILLING!
				  			CHILLY()
				  		elseif message.diff >= 4 then
				  			-- COOLIING
				  			COOL()
				  		else
				  			-- ALL IS GOOD IN THE WORLD
				  			HARMONY()
				  		end
			       
			       end)
end

print("Started server")
server()
STARTUP()
cord.enter_loop()