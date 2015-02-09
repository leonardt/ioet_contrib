local TMP006_B0 = -0.0000294
local TMP006_B1 = -0.00000057
local TMP006_B2 = 0.00000000463
local TMP006_C2 = 13.4
local TMP006_TREF = 298.15
local TMP006_A2 = -0.00001678
local TMP006_A1 = 0.00175
local TMP006_S0  = 6.4  -- * 10^-14

-- Read raw sensor temperature
function raw_temp(temp)
  return temp/4 -- temp <<= 2
end

-- Read raw thermopile voltage
function raw_volt(volt)
  return volt
end

-- Calculate object temperature based on raw sensor temp and thermopile voltage
function get_temp(temp, volt) 
  local Tdie = raw_temp(temp);
  local Vobj = raw_volt(volt);
  Vobj = Vobj * 156.25;  -- 156.25 nV per LSB
  Vobj = Vobj / 1000000000; -- nV -> V
  Tdie = Tdie * 0.03125; -- convert to celsius
  Tdie = Tdie + 273.15; -- convert to kelvin

  -- Equations for calculating temperature found in section 5.1 in the user guide
  local tdie_tref = Tdie - TMP006_TREF;
  local S = (1 + TMP006_A1 * tdie_tref + 
      TMP006_A2 * tdie_tref * tdie_tref);
  S = S * TMP006_S0;
  S = S / 10000000;
  S = S / 10000000;

  local Vos = TMP006_B0 + TMP006_B1 * tdie_tref + TMP006_B2 * tdie_tref * tdie_tref;
  local fVobj = (Vobj - Vos) + TMP006_C2 * (Vobj - Vos) * (Vobj - Vos);
  local Tobj = root4(Tdie * Tdie * Tdie * Tdie + fVobj/S);

  Tobj = Tobj - 273.15; -- Kelvin -> *C
  return Tobj;
end
-- 4th root
function root4(n)
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
print(get_temp(5000, -4000))
