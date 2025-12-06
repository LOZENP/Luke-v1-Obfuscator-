-- simple.lua
-- A simple script to test obfuscation

print("Starting the program...")
wait(1)

local message = "Hello, World!"
print(message)

warn("This is a warning message")

wait(0.5)

print("Processing data...")
local result = 42
print("Result: " .. result)

wait(1)

loadstring("print('This is dynamically loaded code')")()

print("Program completed!")
