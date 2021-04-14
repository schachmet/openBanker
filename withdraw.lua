local component = require("component")
local modem = component.modem
local term = require("term")
local event = require("event")

term.clear()
io.write("Username: ")
print(" ")
local user = io.read()
io.write("Pin: ")
print(" ")
local pinT = term.read({}, true, {}, "*")
local pin = pinT:sub(1, -2)

print(" ")
modem.open(7000)
modem.broadcast(7000, user)

local loop = true

while loop do
  local _, _, from, port, _, message = event.pull("modem_message")

  if message == "OK" then
    host = from
    loop = false
  end
end

modem.send(host, 7000, pin)

io.write("Amount: ")
amount = io.read()

modem.send(host, 7000, amount)

local loop = true

while loop do
  local _, _, from, port, _, message = event.pull("modem_message")

  if host == from then
    loop = false
    print(" ")  
    if message == "OK" then
      print("Authorized to withdraw " ..amount.."$")
    elseif message == "NOMONEY" then
      print("Not enough account balance")
    elseif message == "WRONGPIN" then
      print("Wrong pin")
    elseif message == "NOUSER" then
      print("User not found.")
    end
  end
end