local component = require("component")
local event = require("event")
local acc = true
local ttf = require("ttf")
local modem = component.modem

modem.open(7000)

local loop = true

print("Waiting for client...")
local _, _, from, port, _, message = event.pull("modem_message")
modem.send(from, port, "OK")

user = message
client = from

while loop do
  local _, _, from, port, _, message = event.pull("modem_message")
  
  if from == client then
    pin = message
    loop = false
  end
end

loop = true

while loop do
  local _, _, from, port, _, message = event.pull("modem_message")
  if from == client then
    amount = message
    data = ttf.load("/accounts/" .. user .. ".txt")
    loop = false
  end
end

for k, v in pairs(data) do
  local usr = v[1]
  local pn = v[2]
  local amnt = v[3]

  if usr == user then
    if pn == pin then
      if amount <= amount then
        amount2 = amnt-amount

        local data = {data={usr, pn, amount2}}
        ttf.save(data, "/accounts/" .. usr .. ".txt")
        modem.send(client, port, "OK")
        os.execute("/home/server")
      else
        modem.send(client, port, "NOMONEY")
        os.execute("/home/server")
      end
    else
      modem.send(client, port, "WRONGPIN")
      os.execute("/home/server")
    end
  else
    modem.send(client, port, "NOUSER")
    os.execute("/home/server")
  end
end