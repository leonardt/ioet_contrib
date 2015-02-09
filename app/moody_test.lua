--[[ TEST MOODY ACTUATORS REFERENCE FILE
     Play behaviors on a per actuator instance. 
]]--

moody = require "moody"
require "cord"



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



-- function LED:new(ledpin)
--    assert(ledpin and storm.io[ledpin], "invalid pin spec")
--    obj = {pin = ledpin}		-- initialize the new object
--    setmetatable(obj, self)	-- associate class methods
--    self.__index = self
--    storm.io.set_mode(storm.io.OUTPUT, storm.io[ledpin])
--    return obj
-- end
	-- new constructor
	function c:new(o)
		assert(o.pin and storm.io[o.pin], "invalid pin spec")
		o = o or {}
		setmetatable(o, c)
		print("Setting output for pin", o.pin)
		storm.io.set_mode(storm.io.OUTPUT, storm.io[o.pin])
		return o
	end

	return c -- new class returned
end




MoodyLED = createClass(moody, LED);

function MoodyLED:play_behavior(name, duration)
	duration = duration or 300
	print("Playing", name, "for", duration, "ms")
	local speedup = duration / 298.0

	c = cord.new(function()
		for i, seq in pairs(self.behaviors[name]) do
			t, intensity = unpack(seq)
			t = t * speedup
			intensity = intensity or 0
			if intensity > 20 then 
				self:off()
			else
				self:on()
			end
			cord.await(storm.os.invokeLater, t * storm.os.MILLISECOND )
			-- print(t, intensity)
		end

		self:off()
	end)
end



blue_led = MoodyLED:new{pin = "D2"}

print("BLUE_LED_MOODY?", blue_led:is_moody())
print("  Available behaviors?")
blue_led:print_behaviors()

-- green_led:time_diff("alternate_on_and_off", 500);
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




