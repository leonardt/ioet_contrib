moody = require "moody"
require "cord"
-- moody_test



local function search(k, plist)
	for i = 1, #plist do
		local v = plist[i][k] -- try ith superclass
		if v then return v end
	end
end

-- Method for multi-class inheritance
-- from Irusalimschy 2013

function createClass(...)
	local c = {} -- new class
	local parents = {...}

	-- class will search for each method in the
	-- list of its paerents

	setmetatable(c, {__index = function(t, k)
		return search(k, parents)
	end})

	-- prepare 'c' to be the metatable of its instances
	c.__index = c

	-- new constructor
	function c:new(o)
		o = o or {}
		setmetatable(o, c)
		return o
	end

	return c -- new class returned
end


MoodyLED = createClass(moody, LED);
green_led = MoodyLED:new("D3")



print("GREEN_LED_MOODY?", green_led:is_moody())
print("  Available behaviors?")
green_led:print_behaviors()

-- green_led:time_diff("alternate_on_and_off", 500);
-- green_led:play_behavior("alternate_on_and_off", 2000);
green_led:on()

blue = LED:new{pin="D2"}

blue:flash(5)

cord.enter_loop()
