LED = require("led")


Moody = {}
-- time, intensity pairs
Moody.behaviors = {
	heartbeat = {{0,255},{18,0.0},{43,254},{64,0.0},{89,254},{155,0.0},{181,254},{202,0.0},{227,254},{295,nil}} , 
	alternate_on_and_off = {{0,254},{20,0.0},{93,255},{160,0.0},{234,255},{300,nil}}, 
	blink_decreasing = {{0,254},{23,0.0},{33,255},{44,0.0},{55,254},{68,0.0},{93,255},{118,0.0},{153,255},{187,0.0},{245,255},{298,nil}}, 
	blink_increasing = {{0,255},{22,0.0},{79,255},{113,0.0},{149,255},{170,0.0},{198,255},{212,0.0},{223,255},{233,0.0},{244,255},{298,nil}}, 
	blink_slow = {{0,254},{23,0},{93,255},{163,0.0},{234,255},{298,nil}}, 
	sos = {{0,255},{12,0.0},{23,254},{33,0.0},{44,255},{55,0.0},{65,255},{86,0},{112,255},{135,0},{160,254},{185,0.0},{209,255},{232,0.0},{241,255},{251,0.0},{262,254},{274,0.0},{284,255},{296,nil}}, 
	transmission_fixed_brightness = {{0,0},{24,254},{57,0},{81,254},{116,0},{127,255},{137,0.0},{162,255},{183,0.0},{207,255},{239,0},{254,254},{276,0.0},{298,nil}}
}

function Moody:print_behaviors()
	for i, b in pairs(self.behaviors) do 
		print("   ", i)
	end
end

function Moody:time_diff(name)
	local b = {self.behaviors[name][1]}
	last_tb = b[1][1]
	for i, tb in pairs(self.behaviors[name]) do
		if i ~= 1 then
			tstamp, intensity = unpack(tb)
			table.insert(b, {tstamp - last_tb, intensity})
			last_tb = tstamp
		end
	end
	return b
end

function Moody:is_moody()
	return true
end

return Moody