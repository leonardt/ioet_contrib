function calc_temp(temp, volt)
	local a1 = 1.75e-3
	local a2 = -1.678e-5
	local tref = 298.15
	local b0 = -2.94e-5
	local b1 = -5.7e-7
	local b2 = 4.63e-9
	local c2 = 13.4
	diff = (temp - tref) 
	diff2 = diff * diff
	S = 1 + (a1 * diff + a2 * diff2)
	Vos = b0 + b1 * diff + b2 * diff2
	f = (volt - Vos) + c2 * ((volt - Vos) * (volt - Vos))
	return pow4_calc(temp * temp * temp * temp + f/S)
end

function pow4_calc(n)
    start = 0
    fin = n
    m = 0
    min_range = 0.0000000001;
     
    while fin - start > min_range do
        m = (start + fin) / 2.0;
        pow4 = m * m * m * m
        temp = pow4 - n; 

        if temp < 0 then 
        	temp = temp * -1
        end
        
        if temp <= min_range then
            return m
        elseif pow4 < n then
            start = m
        else
            fin = m
        end
    end
    return m
end