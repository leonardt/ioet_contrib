function calc_temp(temp, volt)
	local a1 = 1.75e-3
	local a2 = 1.678e-5
	local tref = 298.15
	local b0 = -2.94e-5
	local b1 = -5.7e-7
	local b2 = 4.63e-9
	local c2 = 13.4
	S = 1 + (a1 * (temp - tref)  + a2 * ((temp - tref) * (temp - tref)))
end