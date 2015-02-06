require "cord"
local REG = {}

-- Create a new I2C register binding
function REG:new(port, address)
    obj = {port=port, address=address}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Read a given register address
function REG:r(reg)
    -- TODO:
    -- create array with address
    -- write address
    -- read register with RSTART
    -- check all return values
    local arr = storm.array.create(1, storm.array.UINT8)
    arr:set(1, reg)
    local status = cord.await(storm.i2c.write, self.port + self.address, storm.i2c.START, arr)
    print(string.format("status of write: %d", status))
    status = cord.await(storm.i2c.read, self.port + self.address, storm.i2c.RSTART + storm.i2c.STOP, arr)
    print(string.format("status of read: %d", status))
    print(string.format("value %d", arr:get(1)))
    return arr:get(1)
end

function REG:w(reg, value)
    -- TODO:
    -- create array with address and value
    -- write
    -- check return value
   local arr = storm.array.create(2, storm.array.UINT8)
   arr:set(1, reg)
   arr:set(2, value)
   local status = cord.await(storm.i2c.write, self.port + self.address, storm.i2c.START + storm.i2c.STOP, arr) 
   if status == storm.i2c.OK then
      print(string.format("Succesful written from 0x%02x", self.address))
   end
end

REG.scan_i2c = function ()
    for i=0x00,0xFE,2 do
        local arr = storm.array.create(1, storm.array.UINT8)
        local rv = cord.await(storm.i2c.read,  storm.i2c.INT + i,  
                        storm.i2c.START + storm.i2c.STOP, arr)
        if (rv == storm.i2c.OK) then
            print (string.format("Device found at 0x%02x",i ));
        end
    end
end

return REG
