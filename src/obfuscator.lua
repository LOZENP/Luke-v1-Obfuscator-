-- obfuscator.lua
-- Main obfuscator module that ties everything together

local Utils = require("src.utils")
local Encoder = require("src.encoder")
local Parser = require("src.parser")
local VMGenerator = require("src.vm_generator")

local Obfuscator = {}

-- Default configuration
local defaultConfig = {
    level = 3,
    controlFlowObfuscation = true,
    stringEncryption = true,
    constantPooling = true,
    deadCodeInjection = true,
    antiDebug = false,
    vmBytecode = true,
    encryptionLayers = 5,
    dummyInstructionRatio = 0.30,
    maxStringChunkSize = 105,
    nameObfuscationStyle = "random"
}

function Obfuscator.setConfigByLevel(config)
    if config.level == 1 then
        -- Light obfuscation
        config.controlFlowObfuscation = true
        config.deadCodeInjection = true
        config.antiDebug = false
        config.encryptionLayers = 1
        config.dummyInstructionRatio = 0.1
    elseif config.level == 2 then
        -- Medium obfuscation
        config.controlFlowObfuscation = true
        config.deadCodeInjection = true
        config.antiDebug = false
        config.encryptionLayers = 1
        config.dummyInstructionRatio = 0.3
    elseif config.level == 3 then
        -- Heavy obfuscation (default)
        config.controlFlowObfuscation = true
        config.deadCodeInjection = true
        config.antiDebug = false
        config.encryptionLayers = 2
        config.dummyInstructionRatio = 0.4
    elseif config.level == 4 then
        -- Extreme obfuscation
        config.controlFlowObfuscation = true
        config.deadCodeInjection = true
        config.antiDebug = false
        config.encryptionLayers = 10
        config.dummyInstructionRatio = 0.30
    end
    
    return config
end

function Obfuscator.obfuscate(code, userConfig)
    -- Initialize random seed
    Utils.randomSeed()
    
    -- Merge user config with defaults
    local config = Utils.deepCopy(defaultConfig)
    if userConfig then
        for k, v in pairs(userConfig) do
            config[k] = v
        end
    end
    
    -- Apply level-based configuration
    config = Obfuscator.setConfigByLevel(config)
    
    -- Validate input
    if not code or code == "" then
        error("No code provided to obfuscate")
    end
    
    -- Create modules
    local encoder = Encoder.new(config)
    local parser = Parser.new(config)
    local vmGenerator = VMGenerator.new(config, encoder)
    
    -- Parse the code into AST
    local ast = parser.parse(code)
    
    -- Generate VM bytecode from AST
    vmGenerator.generateFromAST(ast)
    
    -- Build the final VM
    local obfuscatedCode = vmGenerator.buildVM()
    
    return obfuscatedCode
end

function Obfuscator.obfuscateFile(inputPath, outputPath, config)
    local file = io.open(inputPath, "r")
    if not file then
        error("Could not open input file: " .. inputPath)
    end
    
    local code = file:read("*all")
    file:close()
    
    local obfuscated = Obfuscator.obfuscate(code, config)
    
    local outFile = io.open(outputPath, "w")
    if not outFile then
        error("Could not open output file: " .. outputPath)
    end
    
    outFile:write(obfuscated)
    outFile:close()
    
    return true
end

function Obfuscator.getVersion()
    return "2.0.0"
end

function Obfuscator.getDefaultConfig()
    return Utils.deepCopy(defaultConfig)
end

return Obfuscator
