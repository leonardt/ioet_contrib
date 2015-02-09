--[[ LED REFERENCE FILE
     Plays all the leds on the StarterShield board. 
     LEDs are arranged red2, red, green blue from the button side. 
]]--
require("cord")
LED = require("led")

blue = LED:new("D2")
blue:flash(20)

green = LED:new("D3")
green:flash(10)

red = LED:new("D4")
red:flash(10)

red2 = LED:new("D5")
red2:flash(10)

cord.enter_loop();