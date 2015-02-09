math = require "math" 

function calc_temp(temp, volt)
	local a1 = 1.75e-3
	local a2 = 1.678e-5
	local tref = 298.15
	local b0 = -2.94e-5
	local b1 = -5.7e-7
	local b2 = 4.63e-9
	local c2 = 13.4
	S = 1 + (a1 * (temp - tref)  + a2 * math.pow(temp-tref, 2)
	Vos = b0 + b1 * (temp - tref) + b2 * math.pow(temp-tref, 2)
	f = (volt - Vos) + c2 * math.pow(volt- Vos, 2)
	return math.pow(math.pow(temp, 4) + f/S, 1/4)
end