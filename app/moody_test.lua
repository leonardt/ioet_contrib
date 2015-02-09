--[[ TEST MOODY ACTUATORS REFERENCE FILE
     Play behaviors on a per actuator instance. 
]]--

require "cord"
MoodyLED = require("MoodyLED")

blue_led = MoodyLED:new{ pin = "D2" }

print("BLUE_LED_MOODY?", blue_led:is_moody())
print("  Available behaviors?")
blue_led:print_behaviors()

storm.os.invokePeriodically(14000 * storm.os.MILLISECOND, function()
	s = cord.new(function()
			for i, b in pairs(blue_led.behaviors) do 
				blue_led:play_behavior(i, 2000)
				cord.await(storm.os.invokeLater, 2100 * storm.os.MILLISECOND)
			end
	end)
end)

cord.enter_loop()




