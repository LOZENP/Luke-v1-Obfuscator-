-- example.lua
-- Example usage of the obfuscator

local Obfuscator = require("src.obfuscator")

-- Example 1: Simple obfuscation
print("=== Example 1: Simple Print Statement ===")
local code1 = [[
print("Hello, World!")
print("This is a test")
wait(1)
warn("Warning message")
]]

local obfuscated1 = Obfuscator.obfuscate(code1, {level = 2})
print("Original code length:", #code1)
print("Obfuscated code length:", #obfuscated1)
print("Compression ratio:", string.format("%.2fx", #obfuscated1 / #code1))
print()

-- Example 2: Heavy obfuscation with all features
print("=== Example 2: Heavy Obfuscation ===")
local code2 = [[
local message = "Secret data"
print(message)
wait(0.5)
warn("Processing...")
loadstring("print('Dynamic code')")()
]]

local obfuscated2 = Obfuscator.obfuscate(code2, {
    level = 3,
    nameObfuscationStyle = "random",
    antiDebug = true
})
print("Obfuscated with level 3")
print("Output length:", #obfuscated2)
print()

-- Example 3: Extreme obfuscation
print("=== Example 3: Extreme Obfuscation ===")
local code3 = [[
print("Top secret")
wait(2)
error("Critical error")
]]

local obfuscated3 = Obfuscator.obfuscate(code3, {
    level = 4,
    nameObfuscationStyle = "chinese",
    encryptionLayers = 3
})
print("Obfuscated with level 4 (Extreme)")
print("Output length:", #obfuscated3)
print()

-- Example 4: Light obfuscation (fast)
print("=== Example 4: Light Obfuscation (Fast) ===")
local code4 = [[
print("Quick test")
warn("Fast obfuscation")
]]

local obfuscated4 = Obfuscator.obfuscate(code4, {level = 1})
print("Obfuscated with level 1 (Light)")
print("Output length:", #obfuscated4)
print()

-- Example 5: Custom configuration
print("=== Example 5: Custom Configuration ===")
local code5 = [[
print("Custom config test")
loadstring("print('Loaded')")()
]]

local customConfig = {
    level = 3,
    nameObfuscationStyle = "readable",
    antiDebug = false,
    deadCodeInjection = true,
    controlFlowObfuscation = true,
    encryptionLayers = 2,
    dummyInstructionRatio = 0.5
}

local obfuscated5 = Obfuscator.obfuscate(code5, customConfig)
print("Obfuscated with custom config")
print("Output length:", #obfuscated5)
print()

-- Save one example to a file
print("=== Saving Example Output ===")
local outFile = io.open("examples/output_example.lua", "w")
if outFile then
    outFile:write("-- Obfuscated by Advanced Lua VM Obfuscator\n")
    outFile:write("-- Original: print('Hello, World!')\n\n")
    outFile:write(obfuscated1)
    outFile:close()
    print("✓ Saved to examples/output_example.lua")
else
    print("✗ Could not save output file")
end

print("\n=== All Examples Completed ===")
