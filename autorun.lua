local user = "user0000" --CHANGE THIS TO YOUR USER

local component = require("component")
local modem = component.modem
local event = require("event")
local term = require("term")
local redstone = component.redstone

term.clear()

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

io.write("Enter pin: ")
local pin = term.read({}, true, {}, "*")

modem.send(host, 7000, pin:sub(1, -2))

print(" ")

io.write("Enter amount to withdraw: ")
local amount = term.read({}, true, {}, "*")

modem.send(host, 7000, amount:sub(1, -2))

loop = true

while loop do
  local _, _, from, port, _, message = event.pull("modem_message")

  if from == host then
    loop = false

    if message == "OK" then
      loop = true
      local count = 1

      while loop do
        redstone.setOutput(3, 15)
        os.sleep(.25)
        redstone.setOutput(3, 0)
        count = count+1
        if count == amount/10+1 then
          loop = false
          print("Thank you, please take your card.")
          os.sleep(5)
          os.execute("reboot")
        end
      end
    elseif message == "NOMONEY" then
      print("Not enough account balance.")
    elseif message == "WRONGPIN" then
      print("Wrong pin.")
    elseif message == "NOUSER" then
      print("User not found.")
    end 
  end
end