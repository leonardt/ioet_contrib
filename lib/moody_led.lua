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

	local c = cord.new(function()
		behavior = self:time_diff(name)

		for i, seq in pairs(behavior) do
			t, intensity = unpack(seq)
			t = t * speedup
			intensity = intensity or 0
			if intensity > 20 then 
				self:off()
			else
				self:on()
			end
			cord.await(storm.os.invokeLater, t * storm.os.MILLISECOND )
		end

		self:off()
	end)
end

return MoodyLED
