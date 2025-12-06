-- vm_generator.lua (HARDENED VERSION)
-- Advanced VM with dynamic opcodes and control flow obfuscation

local Utils = require("src.utils")

local VMGenerator = {}

function VMGenerator.new(config, encoder)
    local self = {
        config = config,
        encoder = encoder,
        instructions = {},
        constants = {},
        varNames = {},
        opcodeMap = {}, -- Dynamic opcode mapping
        fakeInstructions = {}
    }
    
    -- Generate random opcode mapping to hide instruction types
    function self.generateOpcodeMap()
        local map = {}
        local used = {}
        
        -- Randomize opcode ranges
        local function getUnusedRange(min, max)
            local range
            repeat
                range = math.random(min, max)
            until not used[range]
            used[range] = true
            return range
        end
        
        map.print = getUnusedRange(1000, 5000)
        map.warn = getUnusedRange(1000, 5000)
        map.loadstring = getUnusedRange(1000, 5000)
        map.wait = getUnusedRange(1000, 5000)
        map.error = getUnusedRange(1000, 5000)
        map.nop = getUnusedRange(100, 999)
        
        return map
    end
    
    function self.generateVarNames(count)
        local names = {}
        local used = {}
        
        for i = 1, count do
            local name
            repeat
                name = Utils.randName(config.nameObfuscationStyle)
            until not used[name]
            
            used[name] = true
            names[i] = name
        end
        
        return names
    end
    
    function self.addConstant(value)
        table.insert(self.constants, value)
        return #self.constants - 1
    end
    
    function self.emitInstruction(opcode, a, b, c)
        table.insert(self.instructions, {opcode, a or 0, b or 0, c or 0})
        return #self.instructions - 1
    end
    
    -- Generate fake instructions that look real
    function self.generateFakeInstruction()
        return {
            math.random(100, 5000),
            math.random(0, 100),
            math.random(0, 100),
            math.random(0, 100)
        }
    end
    
    function self.injectDummyInstructions(count)
        for i = 1, count do
            local fake = self.generateFakeInstruction()
            self.emitInstruction(fake[1], fake[2], fake[3], fake[4])
        end
    end
    
    -- Inject fake branches and loops
    function self.injectControlFlowObfuscation()
        if not config.controlFlowObfuscation then return end
        
        for i = 1, math.random(5, 10) do
            -- Fake conditional jump
            self.emitInstruction(
                math.random(5000, 6000),
                math.random(1, 20),
                math.random(1, #self.instructions),
                math.random(0, 1)
            )
        end
    end
    
    function self.generateFromAST(ast)
        -- Generate dynamic opcode map
        self.opcodeMap = self.generateOpcodeMap()
        
        for idx, instr in ipairs(ast.instructions) do
            -- Add fake instructions before real ones
            if config.deadCodeInjection and math.random() < 0.3 then
                self.injectDummyInstructions(math.random(1, 3))
            end
            
            if instr.type == "print" then
                local encrypted = self.encoder.encryptString(instr.args[1], config.encryptionLayers)
                local constIdx = self.addConstant(encrypted)
                self.emitInstruction(self.opcodeMap.print, 0, constIdx, 0)
                
            elseif instr.type == "warn" then
                local encrypted = self.encoder.encryptString(instr.args[1], config.encryptionLayers)
                local constIdx = self.addConstant(encrypted)
                self.emitInstruction(self.opcodeMap.warn, 0, constIdx, 0)
                
            elseif instr.type == "loadstring" then
                local encrypted = self.encoder.encryptString(instr.args[1], config.encryptionLayers)
                local constIdx = self.addConstant(encrypted)
                self.emitInstruction(self.opcodeMap.loadstring, 0, constIdx, 0)
                
            elseif instr.type == "error" then
                local encrypted = self.encoder.encryptString(instr.args[1], config.encryptionLayers)
                local constIdx = self.addConstant(encrypted)
                self.emitInstruction(self.opcodeMap.error, 0, constIdx, 0)
                
            elseif instr.type == "wait" then
                self.emitInstruction(self.opcodeMap.wait, 0, instr.args[1] * 1000, 0)
            else
                self.emitInstruction(self.opcodeMap.nop, 0, 0, 0)
            end
            
            -- Add dummy instructions after
            if config.deadCodeInjection then
                local dummyCount = math.floor(ast.metadata.complexity * config.dummyInstructionRatio)
                self.injectDummyInstructions(dummyCount)
            end
        end
        
        self.injectControlFlowObfuscation()
    end
    
    function self.buildVM()
        self.varNames = self.generateVarNames(40)
        local vn = self.varNames
        
        local keys = self.encoder.getKeyStrings()
        local fakeKeys = self.encoder.generateFakeKeys(5)
        
        -- Encrypt all instructions
        local encryptedInstrs = {}
        for i, instr in ipairs(self.instructions) do
            local enc = self.encoder.encryptInstruction(instr, i)
            encryptedInstrs[i] = "{" .. table.concat(enc, ",") .. "}"
        end
        
        -- Build constant pool
        local constStrs = {}
        for _, const in ipairs(self.constants) do
            local chunkStrs = {}
            for _, chunk in ipairs(const) do
                table.insert(chunkStrs, "{{" .. table.concat(chunk.data, ",") .. "}," .. chunk.size .. "," .. chunk.index .. "}")
            end
            table.insert(constStrs, "{" .. table.concat(chunkStrs, ",") .. "}")
        end
        
        -- Anti-debug with multiple checks
        local antiDebug = ""
        if config.antiDebug then
            antiDebug = "local " .. vn[38] .. "=debug;" ..
                       "local " .. vn[39] .. "=getfenv or function()return _ENV end;" ..
                       "if " .. vn[38] .. " then " ..
                       "if " .. vn[38] .. ".getinfo or " .. vn[38] .. ".getupvalue or " .. vn[38] .. ".setupvalue then " ..
                       "error(string.char(68,101,98,117,103,32,100,101,116,101,99,116,101,100))end;" ..
                       "end;" ..
                       "if " .. vn[39] .. "() and " .. vn[39] .. "().debug then error('')end;"
        end
        
        -- Opcode map as encrypted data
        local opcodeMapStr = vn[35] .. "={" ..
                            "[" .. self.opcodeMap.print .. "]=1," ..
                            "[" .. self.opcodeMap.warn .. "]=2," ..
                            "[" .. self.opcodeMap.loadstring .. "]=3," ..
                            "[" .. self.opcodeMap.wait .. "]=4," ..
                            "[" .. self.opcodeMap.error .. "]=5" ..
                            "};"
        
        -- Inject fake keys as misdirection
        local fakeKeyDecls = ""
        for i, fk in ipairs(fakeKeys) do
            fakeKeyDecls = fakeKeyDecls .. "local " .. vn[20 + i] .. "={" .. fk .. "};"
        end
        
        -- Advanced XOR with rotation (matching encoder)
        local advXorFunc = "local function " .. vn[5] .. "(" .. vn[6] .. "," .. vn[7] .. "," .. vn[36] .. "," .. vn[37] .. ")" ..
                          "local " .. vn[8] .. "=0;" ..
                          "local " .. vn[9] .. "=1;" ..
                          "while " .. vn[6] .. ">0 or " .. vn[7] .. ">0 do " ..
                          "if " .. vn[6] .. "%2~=" .. vn[7] .. "%2 then " ..
                          vn[8] .. "=" .. vn[8] .. "+" .. vn[9] .. ";end;" ..
                          vn[9] .. "=" .. vn[9] .. "*2;" ..
                          vn[6] .. "=math.floor(" .. vn[6] .. "/2);" ..
                          vn[7] .. "=math.floor(" .. vn[7] .. "/2);end;" ..
                          "local " .. vn[40] .. "=(" .. vn[36] .. "%8);" ..
                          vn[8] .. "=((" .. vn[8] .. "<<" .. vn[40] .. ")|(" .. vn[8] .. ">>(8-" .. vn[40] .. ")))&0xFF;" ..
                          vn[8] .. "=0;" .. vn[9] .. "=1;" ..
                          "while " .. vn[8] .. ">0 or " .. vn[37] .. ">0 do " ..
                          "if " .. vn[8] .. "%2~=" .. vn[37] .. "%2 then " ..
                          vn[8] .. "=" .. vn[8] .. "+" .. vn[9] .. ";end;" ..
                          vn[9] .. "=" .. vn[9] .. "*2;" ..
                          vn[8] .. "=math.floor(" .. vn[8] .. "/2);" ..
                          vn[37] .. "=math.floor(" .. vn[37] .. "/2);end;" ..
                          "return " .. vn[8] .. ";end;"
        
        -- Chunk-based string decryption
        local decryptFunc = "local function " .. vn[10] .. "(" .. vn[11] .. "," .. vn[29] .. ")" ..
                           "local " .. vn[30] .. "=" .. vn[29] .. " or 1;" ..
                           "local " .. vn[12] .. "='';" ..
                           "local " .. vn[31] .. "=0;" ..
                           "for " .. vn[32] .. "=1,#" .. vn[11] .. " do " ..
                           "local " .. vn[33] .. "=" .. vn[11] .. "[" .. vn[32] .. "];" ..
                           "local " .. vn[34] .. "=" .. vn[33] .. "[1];" ..
                           "for " .. vn[13] .. "=1,#" .. vn[34] .. " do " ..
                           vn[31] .. "=" .. vn[31] .. "+1;" ..
                           "local " .. vn[14] .. "=" .. vn[34] .. "[" .. vn[13] .. "];" ..
                           "local " .. vn[28] .. "=" .. vn[4] .. "[((" .. vn[31] .. "-1)%" .. #self.encoder.saltKey .. ")+1];" ..
                           vn[14] .. "=" .. vn[5] .. "(" .. vn[14] .. "," .. vn[3] .. "[((" .. vn[31] .. "-1)%64)+1]," .. vn[31] .. "," .. vn[28] .. ");" ..
                           "if " .. vn[30] .. ">=2 then " ..
                           "local " .. vn[27] .. "=#" .. vn[12] .. "-" .. vn[31] .. "+1;" ..
                           vn[28] .. "=" .. vn[4] .. "[((" .. vn[27] .. "-1)%" .. #self.encoder.saltKey .. ")+1];" ..
                           vn[14] .. "=" .. vn[5] .. "(" .. vn[14] .. "," .. vn[2] .. "[((" .. vn[27] .. "-1)%128)+1]," .. vn[27] .. "," .. vn[28] .. ");end;" ..
                           "if " .. vn[30] .. ">=3 then " ..
                           "local " .. vn[26] .. "=(" .. vn[31] .. "*" .. vn[32] .. ")%256;" ..
                           vn[14] .. "=" .. vn[14] .. "~" .. vn[1] .. "[((" .. vn[26] .. "-1)%32)+1];" ..
                           vn[14] .. "=(" .. vn[14] .. "-" .. vn[32] .. ")%256;end;" ..
                           vn[12] .. "=" .. vn[12] .. "..string.char(" .. vn[14] .. ");end;end;" ..
                           "return " .. vn[12] .. ";end;"
        
        -- Complex instruction decoder with dynamic opcodes
        local decoderFunc = "local function " .. vn[15] .. "(" .. vn[16] .. ")" ..
                           "local " .. vn[17] .. "={};" ..
                           "for " .. vn[13] .. "=1,#" .. vn[16] .. " do " ..
                           "local " .. vn[18] .. "=" .. vn[16] .. "[" .. vn[13] .. "];" ..
                           "local " .. vn[19] .. "={};" ..
                           "local " .. vn[26] .. "=(" .. vn[13] .. "*7+13)%256;" ..
                           "for " .. vn[27] .. "=1,4 do " ..
                           "local " .. vn[28] .. "=" .. vn[18] .. "[" .. vn[27] .. "];" ..
                           vn[28] .. "=(" .. vn[28] .. "-" .. vn[13] .. ")%256;" ..
                           vn[28] .. "=" .. vn[28] .. "~" .. vn[26] .. ";" ..
                           vn[28] .. "=" .. vn[28] .. "~" .. vn[1] .. "[((" .. vn[13] .. "-1)%256)+1];" ..
                           vn[19] .. "[" .. vn[27] .. "]=" .. vn[28] .. ";end;" ..
                           vn[17] .. "[" .. vn[13] .. "]=" .. vn[19] .. ";end;" ..
                           "local " .. vn[20] .. "=1;" ..
                           "while " .. vn[20] .. "<=#" .. vn[17] .. " do " ..
                           "local " .. vn[22] .. "=" .. vn[17] .. "[" .. vn[20] .. "];" ..
                           "local " .. vn[23] .. "," .. vn[24] .. "," .. vn[25] .. "=" .. vn[22] .. "[1]," .. vn[22] .. "[2]," .. vn[22] .. "[3]," .. vn[22] .. "[4];" ..
                           "local " .. vn[21] .. "=" .. vn[35] .. "[" .. vn[23] .. "];" ..
                           "if " .. vn[21] .. "==1 then " ..
                           "print(" .. vn[10] .. "(" .. vn[11] .. "[" .. vn[25] .. "+1]," .. config.encryptionLayers .. "));" ..
                           "elseif " .. vn[21] .. "==2 then " ..
                           "warn(" .. vn[10] .. "(" .. vn[11] .. "[" .. vn[25] .. "+1]," .. config.encryptionLayers .. "));" ..
                           "elseif " .. vn[21] .. "==3 then " ..
                           "loadstring(" .. vn[10] .. "(" .. vn[11] .. "[" .. vn[25] .. "+1]," .. config.encryptionLayers .. "))();" ..
                           "elseif " .. vn[21] .. "==4 then " ..
                           "wait(" .. vn[25] .. "/1000);" ..
                           "elseif " .. vn[21] .. "==5 then " ..
                           "error(" .. vn[10] .. "(" .. vn[11] .. "[" .. vn[25] .. "+1]," .. config.encryptionLayers .. "));end;" ..
                           vn[20] .. "=" .. vn[20] .. "+1;end;end;"
        
        -- Build complete VM
        local vm = "return(function(...)  " ..
                   antiDebug ..
                   "local " .. vn[1] .. "={" .. keys.tertiary .. "};" ..
                   "local " .. vn[2] .. "={" .. keys.secondary .. "};" ..
                   "local " .. vn[3] .. "={" .. keys.string .. "};" ..
                   "local " .. vn[4] .. "={" .. keys.salt .. "};" ..
                   fakeKeyDecls ..
                   "local " .. vn[11] .. "={" .. table.concat(constStrs, ",") .. "};" ..
                   opcodeMapStr ..
                   advXorFunc ..
                   decryptFunc ..
                   decoderFunc ..
                   "local " .. vn[16] .. "={" .. table.concat(encryptedInstrs, ",") .. "};" ..
                   "local " .. vn[1] .. "={" .. keys.primary .. "};" .. -- Redefine after fake keys
                   "return " .. vn[15] .. "(" .. vn[16] .. ");end)(...)"
        
        return vm
    end
    
    return self
end

return VMGenerator
