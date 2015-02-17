require("cord")
cport = 49152

csock = storm.net.udpsocket(cport, 
			    function(payload, from, port)
			    end)

local svc_manifest = {id="HW-Defined-SW",
                      publishToChannel={ s="sendMessage"}
                      subscribeToChannel={ s="subscribe"}}

local msg = storm.mp.pack(svc_manifest)
storm.os.invokePeriodically(5*storm.os.SECOND, function()
                            storm.net.sendto(csock, msg, "ff02::1", 1525)
end)

local channel_subscribers = {}

local service_port = 1526
function service_handler(payload, from, port)
   local message = storm.mp.unpack(payload)
   if #message ~= 2 then
      print("Malformed message")
      response = {1, "Error: Malformed Message, should be length 2"}
   else
     local action = message[0]
     if action == 'publishToChannel' then
        local channel = message[1][0]
        local msg = storm.mp.pack(message[1][1])
        local subscribers = channel_subscribers[channel]
        for i=1,#subscribers do
           storm.net.sendto(csock, msg, subscribers[i], service_port)
        end
        response = {0, "Success"}
     elseif action == 'subscribeToChannel' then
        local channel = message[1]
        local entry = channel_subscribers[channel]
        if not entry then
           entry = {}
           channel_subscribers[channel] = entry
        end
        entry[#entry] = from
        response = {0, "Success"}
     else
        print("Malformed request")
        response = {2, "Error: Unknown action"}
     end
   end
   storm.net.sendto(csock, response, from, service_port)
end
