require("cord")
require("storm")
REG = require("i2creg")
local TEMPI2C = {}

-- see here for constants: https://www.sparkfun.com/products/11859

-- Constants for calculating object temperature
-- TMP006_B0 = -0.0000294
-- TMP006_B1 = -0.00000057
-- TMP006_B2 = 0.00000000463
-- TMP006_C2 = 13.4
-- TMP006_TREF = 298.15
-- TMP006_A2 = -0.00001678
-- TMP006_A1 = 0.00175
-- TMP006_S0 = 6.4  // * 10^-14

-- Configuration Settings
TMP006_CFG_RESET    = 0x8000
TMP006_CFG_MODEON   = 0x7000
TMP006_CFG_1SAMPLE  = 0x0000
TMP006_CFG_2SAMPLE  = 0x0200
TMP006_CFG_4SAMPLE  = 0x0400
TMP006_CFG_8SAMPLE  = 0x0600
TMP006_CFG_16SAMPLE = 0x0800
TMP006_CFG_DRDYEN   = 0x0100
TMP006_CFG_DRDY     = 0x0080

-- Registers to read thermopile voltage and sensor temperature
TMP006_VOBJ  = 0x00
TMP006_TAMB = 0x01
TMP006_CONFIG = 0x02

-- function calc_temp(temp, volt)
--   local a1 = .00175
--   local a2 = -.00001678
--   local tref = 298.15
--   local b0 = -.0000294
--   local b1 = -.00000057
--   local b2 = .00000000463
--   local c2 = 13.4
--   diff = (temp - tref) 
--   diff2 = diff * diff
--   S = 1 + (a1 * diff + a2 * diff2)
--   Vos = b0 + b1 * diff + b2 * diff2
--   f = (volt - Vos) + c2 * ((volt - Vos) * (volt - Vos))
--   return pow4_calc(temp * temp * temp * temp + f/S)
-- end

-- function pow4_calc(n)
--     start = 0
--     fin = n
--     m = 0
--     min_range = 0.0000000001;
     
--     while fin - start > min_range do
--         m = (start + fin) / 2.0;
--         pow4 = m * m * m * m
--         temp = pow4 - n; 

--         if temp < 0 then 
--         	temp = temp * -1
--         end
        
--         if temp <= min_range then
--             return m
--         elseif pow4 < n then
--             start = m
--         else
--             fin = m
--         end
--     end
--     return m
-- end

-- function pow4_calc(n)
--     start = 0
--     fin = n
--     m = 0
--     min_range = 0.0000000001;
     
--     while fin - start > min_range do
--         m = (start + fin) / 2.0;
--         pow4 = m * m * m * m
--         temp = pow4 - n; 

--         if temp < 0 then 
--         	temp = temp * -1
--         end
        
--         if temp <= min_range then
--             return m
--         elseif pow4 < n then
--             start = m
--         else
--             fin = m
--         end
--     end
--     return m
-- end

function TEMPI2C:new()
    print('TEMPI2C:new() called')
   local obj = {port=storm.i2c.INT, addr= 0x80,
                reg=REG:new(storm.i2c.INT, 0x80)}
   setmetatable(obj, self)
   self.__index = self
   cord.new(function() 
     obj:init()
   end)
   return obj
end

function TEMPI2C:init()
  self.reg:w(TMP006_CONFIG, TMP006_CFG_DRDYEN + TMP006_CFG_MODEON + TMP006_CFG_8SAMPLE)
end

function TEMPI2C:get_reg(reg)
  local addr = storm.array.create(1, storm.array.UINT8)
  addr:set(1,reg)

  local rv = cord.await(storm.i2c.write,  self.port + self.addr,  storm.i2c.START, addr)
  if (rv ~= storm.i2c.OK) then
      print ("ERROR ON I2C: ",rv)
  end


  local dat = storm.array.create(1, storm.array.UINT16) -- not sure about endianness
  rv = cord.await(storm.i2c.read, self.port + self.addr, storm.i2c.RSTART + storm.i2c.STOP, dat)
  if (rv ~= storm.i2c.OK) then
      print ("ERROR ON I2C: ",rv)
  end

  return dat:get_as(storm.array.INT16_BE,0)
end

function TEMPI2C:get()
  local voltage = self:get_reg(TMP006_VOBJ)
  local tamb = self:get_reg(TMP006_TAMB)
  print(voltage, tamb)
  print("temperature calculation: ", tamb)
  return tamb
end

return TEMPI2C
