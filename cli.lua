-- cli.lua
-- Command-line interface for the obfuscator

local Obfuscator = require("src.obfuscator")

local function printUsage()
    print([[
Advanced Lua VM Obfuscator v]] .. Obfuscator.getVersion() .. [[

Usage:
    lua cli.lua <input> <output> [options]

Arguments:
    <input>     Input Lua file to obfuscate
    <output>    Output file for obfuscated code

Options:
    --level <1-4>           Obfuscation level (default: 3)
                            1 = Light, 2 = Medium, 3 = Heavy, 4 = Extreme
    
    --style <style>         Variable naming style (default: random)
                            random, readable, chinese, unicode
    
    --no-antidbg           Disable anti-debugging
    --no-deadcode          Disable dead code injection
    --no-controlflow       Disable control flow obfuscation
    
    --layers <1-3>         Encryption layers (default: 2)
    --dummy-ratio <0-1>    Dummy instruction ratio (default: 0.4)
    
    --help, -h             Show this help message

Examples:
    lua cli.lua script.lua obfuscated.lua
    lua cli.lua script.lua obfuscated.lua --level 4
    lua cli.lua script.lua obfuscated.lua --level 2 --style readable
    lua cli.lua script.lua obfuscated.lua --no-antidbg --layers 1
]])
end

local function parseArgs(args)
    local config = {}
    local inputFile, outputFile
    
    local i = 1
    while i <= #args do
        local arg = args[i]
        
        if arg == "--help" or arg == "-h" then
            printUsage()
            os.exit(0)
        elseif arg == "--level" then
            i = i + 1
            config.level = tonumber(args[i])
            if not config.level or config.level < 1 or config.level > 4 then
                print("Error: Invalid level. Must be 1-4")
                os.exit(1)
            end
        elseif arg == "--style" then
            i = i + 1
            config.nameObfuscationStyle = args[i]
            if not (config.nameObfuscationStyle == "random" or 
                   config.nameObfuscationStyle == "readable" or 
                   config.nameObfuscationStyle == "chinese" or
                   config.nameObfuscationStyle == "unicode") then
                print("Error: Invalid style. Must be: random, readable, chinese, or unicode")
                os.exit(1)
            end
        elseif arg == "--no-antidbg" then
            config.antiDebug = false
        elseif arg == "--no-deadcode" then
            config.deadCodeInjection = false
        elseif arg == "--no-controlflow" then
            config.controlFlowObfuscation = false
        elseif arg == "--layers" then
            i = i + 1
            config.encryptionLayers = tonumber(args[i])
            if not config.encryptionLayers or config.encryptionLayers < 1 or config.encryptionLayers > 3 then
                print("Error: Invalid layers. Must be 1-3")
                os.exit(1)
            end
        elseif arg == "--dummy-ratio" then
            i = i + 1
            config.dummyInstructionRatio = tonumber(args[i])
            if not config.dummyInstructionRatio or config.dummyInstructionRatio < 0 or config.dummyInstructionRatio > 1 then
                print("Error: Invalid dummy ratio. Must be 0-1")
                os.exit(1)
            end
        elseif not inputFile then
            inputFile = arg
        elseif not outputFile then
            outputFile = arg
        else
            print("Error: Unknown argument: " .. arg)
            printUsage()
            os.exit(1)
        end
        
        i = i + 1
    end
    
    return inputFile, outputFile, config
end

local function main(args)
    if #args == 0 then
        printUsage()
        os.exit(0)
    end
    
    local inputFile, outputFile, config = parseArgs(args)
    
    if not inputFile or not outputFile then
        print("Error: Input and output files are required")
        printUsage()
        os.exit(1)
    end
    
    print("Advanced Lua VM Obfuscator v" .. Obfuscator.getVersion())
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Input:  " .. inputFile)
    print("Output: " .. outputFile)
    print("Level:  " .. (config.level or 3))
    print("Style:  " .. (config.nameObfuscationStyle or "random"))
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    local startTime = os.clock()
    
    local success, err = pcall(function()
        Obfuscator.obfuscateFile(inputFile, outputFile, config)
    end)
    
    local endTime = os.clock()
    local elapsed = endTime - startTime
    
    if success then
        print("✓ Obfuscation completed successfully!")
        print(string.format("✓ Time taken: %.2f seconds", elapsed))
        
        -- Get file sizes
        local inFile = io.open(inputFile, "r")
        local outFile = io.open(outputFile, "r")
        if inFile and outFile then
            local inSize = #inFile:read("*all")
            local outSize = #outFile:read("*all")
            inFile:close()
            outFile:close()
            
            print(string.format("✓ Input size:  %d bytes", inSize))
            print(string.format("✓ Output size: %d bytes (%.1fx)", outSize, outSize / inSize))
        end
    else
        print("✗ Obfuscation failed!")
        print("✗ Error: " .. tostring(err))
        os.exit(1)
    end
end

-- Run the CLI
main(arg)
