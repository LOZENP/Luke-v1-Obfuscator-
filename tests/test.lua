-- test_obfuscator.lua
-- Test suite for the obfuscator

local Obfuscator = require("src.obfuscator")

local tests = {}
local passed = 0
local failed = 0

local function test(name, fn)
    io.write("Testing " .. name .. "... ")
    local success, err = pcall(fn)
    if success then
        print("✓ PASSED")
        passed = passed + 1
    else
        print("✗ FAILED")
        print("  Error: " .. tostring(err))
        failed = failed + 1
    end
end

local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

-- Test 1: Basic obfuscation
test("Basic obfuscation", function()
    local code = [[print("Hello")]]
    local result = Obfuscator.obfuscate(code, {level = 1})
    assert(result and #result > 0, "Obfuscation returned empty result")
    assert(#result > #code, "Obfuscated code should be longer")
end)

-- Test 2: Empty code handling
test("Empty code handling", function()
    local success = pcall(function()
        Obfuscator.obfuscate("", {level = 1})
    end)
    assert(not success, "Should error on empty code")
end)

-- Test 3: Multiple statements
test("Multiple statements", function()
    local code = [[
        print("Line 1")
        wait(1)
        warn("Line 2")
        print("Line 3")
    ]]
    local result = Obfuscator.obfuscate(code, {level = 2})
    assert(result and #result > 0, "Failed to obfuscate multiple statements")
end)

-- Test 4: Level 1 obfuscation
test("Level 1 obfuscation", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {level = 1})
    assert(result:find("return%(function"), "Should contain VM wrapper")
end)

-- Test 5: Level 2 obfuscation
test("Level 2 obfuscation", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {level = 2})
    assert(result and #result > 0, "Level 2 failed")
end)

-- Test 6: Level 3 obfuscation
test("Level 3 obfuscation", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {level = 3})
    assert(result and #result > 0, "Level 3 failed")
end)

-- Test 7: Level 4 obfuscation
test("Level 4 obfuscation", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {level = 4})
    assert(result and #result > 0, "Level 4 failed")
end)

-- Test 8: Anti-debug option
test("Anti-debug option", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {level = 3, antiDebug = true})
    assert(result:find("debug"), "Should contain anti-debug code")
end)

-- Test 9: No anti-debug
test("No anti-debug", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {level = 3, antiDebug = false})
    assert(result and #result > 0, "Should work without anti-debug")
end)

-- Test 10: Different naming styles
test("Random naming style", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {
        level = 2, 
        nameObfuscationStyle = "random"
    })
    assert(result and #result > 0, "Random style failed")
end)

test("Readable naming style", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {
        level = 2, 
        nameObfuscationStyle = "readable"
    })
    assert(result and #result > 0, "Readable style failed")
end)

test("Chinese naming style", function()
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, {
        level = 2, 
        nameObfuscationStyle = "chinese"
    })
    assert(result and #result > 0, "Chinese style failed")
end)

-- Test 11: String encryption
test("String encryption", function()
    local code = [[print("Secret message")]]
    local result = Obfuscator.obfuscate(code, {
        level = 2,
        stringEncryption = true
    })
    assert(not result:find("Secret message"), "String should be encrypted")
end)

-- Test 12: Wait function
test("Wait function", function()
    local code = [[wait(5)]]
    local result = Obfuscator.obfuscate(code, {level = 2})
    assert(result and #result > 0, "Wait function failed")
end)

-- Test 13: Loadstring
test("Loadstring function", function()
    local code = [[loadstring("print('test')")()]]
    local result = Obfuscator.obfuscate(code, {level = 2})
    assert(result and #result > 0, "Loadstring failed")
end)

-- Test 14: Warn function
test("Warn function", function()
    local code = [[warn("Warning!")]]
    local result = Obfuscator.obfuscate(code, {level = 2})
    assert(result and #result > 0, "Warn function failed")
end)

-- Test 15: Mixed code
test("Mixed code", function()
    local code = [[
        print("Start")
        local x = 10
        wait(1)
        warn("Middle")
        loadstring("print('dynamic')")()
        print("End")
    ]]
    local result = Obfuscator.obfuscate(code, {level = 3})
    assert(result and #result > 0, "Mixed code failed")
end)

-- Test 16: File operations
test("File obfuscation", function()
    -- Create a test input file
    local testInput = "tests/test_input.lua"
    local testOutput = "tests/test_output.lua"
    
    local f = io.open(testInput, "w")
    f:write([[print("File test")]])
    f:close()
    
    Obfuscator.obfuscateFile(testInput, testOutput, {level = 2})
    
    -- Check if output exists
    local outf = io.open(testOutput, "r")
    assert(outf, "Output file was not created")
    local content = outf:read("*all")
    outf:close()
    assert(#content > 0, "Output file is empty")
    
    -- Clean up
    os.remove(testInput)
    os.remove(testOutput)
end)

-- Test 17: Large code
test("Large code", function()
    local code = ""
    for i = 1, 100 do
        code = code .. 'print("Line ' .. i .. '")\n'
    end
    local result = Obfuscator.obfuscate(code, {level = 2})
    assert(result and #result > 0, "Large code failed")
end)

-- Test 18: Custom config merge
test("Custom config merge", function()
    local config = {
        level = 3,
        antiDebug = false,
        dummyInstructionRatio = 0.8
    }
    local code = [[print("Test")]]
    local result = Obfuscator.obfuscate(code, config)
    assert(result and #result > 0, "Config merge failed")
end)

-- Test 19: Version check
test("Version check", function()
    local version = Obfuscator.getVersion()
    assert(version and type(version) == "string", "Version should be a string")
    assert(version:match("%d+%.%d+%.%d+"), "Version should be in X.Y.Z format")
end)

-- Test 20: Default config
test("Default config", function()
    local config = Obfuscator.getDefaultConfig()
    assert(config, "Should return config")
    assert(config.level, "Config should have level")
    assert(type(config.level) == "number", "Level should be a number")
end)

-- Print results
print("\n" .. string.rep("=", 50))
print("Test Results:")
print("  Passed: " .. passed)
print("  Failed: " .. failed)
print("  Total:  " .. (passed + failed))
print(string.rep("=", 50))

if failed == 0 then
    print("✓ All tests passed!")
else
    print("✗ Some tests failed")
    os.exit(1)
end
