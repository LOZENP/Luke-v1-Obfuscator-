-- vm_generator.lua
-- Virtual Machine bytecode generator

local Utils = require("src.utils")

local VMGenerator = {}

function VMGenerator.new(config, encoder)
    local self = {
        config = config,
        encoder = encoder,
        instructions = {},
        constants = {},
        varNames = {},
        labels = {}
    }
    
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
    
    function self.injectDummyInstructions(count)
        for i = 1, count do
            local dummyOp = math.random(100, 499)
            self.emitInstruction(
                dummyOp,
                math.random(0, 50),
                math.random(0, 50),
                math.random(0, 50)
            )
        end
    end
    
    function self.injectControlFlowObfuscation()
        if not config.controlFlowObfuscation then return end
        
        -- Add fake conditional jumps
        for i = 1, math.random(2, 5) do
            self.emitInstruction(
                math.random(1200, 1300), -- Fake jump opcode
                math.random(1, 10),
                math.random(1, #self.instructions),
                0
            )
        end
    end
    
    function self.generateFromAST(ast)
        for _, instr in ipairs(ast.instructions) do
            if instr.type == "print" or instr.type == "warn" or instr.type == "loadstring" or instr.type == "error" then
                local encrypted = self.encoder.encryptString(instr.args[1], config.encryptionLayers)
                local constIdx = self.addConstant(encrypted)
                self.emitInstruction(instr.opcode, 0, constIdx, 0)
                
                if config.deadCodeInjection then
                    local dummyCount = math.floor(ast.metadata.complexity * config.dummyInstructionRatio)
                    self.injectDummyInstructions(dummyCount)
                end
                
            elseif instr.type == "wait" then
                self.emitInstruction(instr.opcode, 0, instr.args[1] * 1000, 0)
                
                if config.deadCodeInjection then
                    self.injectDummyInstructions(math.floor(ast.metadata.complexity * config.dummyInstructionRatio))
                end
                
            elseif instr.type == "assign" or instr.type == "function" then
                self.emitInstruction(instr.opcode, 0, 0, 0)
                
                if config.deadCodeInjection then
                    self.injectDummyInstructions(math.floor(ast.metadata.complexity * config.dummyInstructionRatio * 0.5))
                end
                
            else
                if config.deadCodeInjection then
                    self.injectDummyInstructions(math.floor(ast.metadata.complexity * config.dummyInstructionRatio * 1.5))
                end
            end
        end
        
        -- Add control flow obfuscation at the end
        self.injectControlFlowObfuscation()
    end
    
    function self.buildVM()
        self.varNames = self.generateVarNames(30)
        local vn = self.varNames
        
        local keys = self.encoder.getKeyStrings()
        
        -- Encrypt all instructions
        local encryptedInstrs = {}
        for i, instr in ipairs(self.instructions) do
            local enc = self.encoder.encryptInstruction(instr, i)
            encryptedInstrs[i] = "{" .. table.concat(enc, ",") .. "}"
        end
        
        -- Build constant pool with encrypted strings
        local constStrs = {}
        for _, const in ipairs(self.constants) do
            table.insert(constStrs, "{" .. table.concat(const, ",") .. "}")
        end
        
        -- Anti-debug code
        local antiDebug = ""
        if config.antiDebug then
            antiDebug = "local " .. vn[28] .. "=debug;" ..
                       "if " .. vn[28] .. " and " .. vn[28] .. ".getinfo then " ..
                       "error('Debugging not allowed') end;"
        end
        
        -- Generate the full VM
        local vm = [[return(function(...)
]] .. antiDebug .. [[
local ]] .. vn[1] .. [[={]] .. keys.primary .. [[};
local ]] .. vn[2] .. [[={]] .. keys.secondary .. [[};
local ]] .. vn[3] .. [[={]] .. keys.string .. [[};
local ]] .. vn[4] .. [[={]] .. table.concat(constStrs, ",") .. [[};

local function ]] .. vn[5] .. [[(]] .. vn[6] .. [[,]] .. vn[7] .. [[)
    local ]] .. vn[8] .. [[=0;
    local ]] .. vn[9] .. [[=1;
    while ]] .. vn[6] .. [[>0 or ]] .. vn[7] .. [[>0 do
        if ]] .. vn[6] .. [[%2~=]] .. vn[7] .. [[%2 then
            ]] .. vn[8] .. [[=]] .. vn[8] .. [[+]] .. vn[9] .. [[;
        end;
        ]] .. vn[9] .. [[=]] .. vn[9] .. [[*2;
        ]] .. vn[6] .. [[=math.floor(]] .. vn[6] .. [[/2);
        ]] .. vn[7] .. [[=math.floor(]] .. vn[7] .. [[/2);
    end;
    return ]] .. vn[8] .. [[;
end;

local function ]] .. vn[10] .. [[(]] .. vn[11] .. [[,]] .. vn[29] .. [[)
    local ]] .. vn[12] .. [[='';
    local ]] .. vn[30] .. [[=]] .. vn[29] .. [[ or 1;
    for ]] .. vn[13] .. [[=1,#]] .. vn[11] .. [[ do
        local ]] .. vn[14] .. [[=]] .. vn[11] .. #[[;
        ]] .. vn[14] .. [[=]] .. vn[5] .. [[(]] .. vn[14] .. [[,]] .. vn[3] .. [[[(((]] .. vn[13] .. [[-1)%64)+1]]);
        if ]] .. vn[30] .. [[>=2 then
            ]] .. vn[14] .. [[=]] .. vn[5] .. [[(]] .. vn[14] .. [[,]] .. vn[2] .. [[[(((]] .. vn[13] .. [[-1)%128)+1]]);
        end;
        ]] .. vn[12] .. [[=]] .. vn[12] .. [[..string.char(]] .. vn[14] .. [[);
    end;
    return ]] .. vn[12] .. [[;
end;

local function ]] .. vn[15] .. [[(]] .. vn[16] .. [[)
    local ]] .. vn[17] .. [[={};
    for ]] .. vn[13] .. [[=1,#]] .. vn[16] .. [[ do
        local ]] .. vn[18] .. [[=]] .. vn[16] .. [[[] .. vn[13] .. [[];
        ]] .. vn[17] .. [[[] .. vn[13] .. [[]={
            ]] .. vn[5] .. [[(]] .. vn[18] .. [[[] .. vn[5] .. [[(]] .. vn[18] .. [[[] .. vn[5] .. [[(]] .. vn[18] .. [[[] .. vn[5] .. [[(]] .. vn[18] .. [[[4],]] .. vn[1] .. [[[(((]] .. vn[13] .. [[-1)%256)+1]])
        };
    end;
    
    local ]] .. vn[19] .. [[,]] .. vn[20] .. [[,]] .. vn[21] .. [[=1,{},{};
    while ]] .. vn[19] .. [[<=#]] .. vn[17] .. [[ do
        local ]] .. vn[22] .. [[=]] .. vn[17] .. [[[] .. vn[19] .. [[];
        local ]] .. vn[23] .. [[,]] .. vn[24] .. [[,]] .. vn[25] .. [[,]] .. vn[26] .. [[=]] .. vn[22] .. [[[1],]] .. vn[22] .. [[[2],]] .. vn[22] .. [[[3],]] .. vn[22] .. [[[4];
        
        if ]] .. vn[23] .. [[>=500 and ]] .. vn[23] .. [[<=600 then
            print(]] .. vn[10] .. [[(]] .. vn[4] .. [[[] .. vn[25] .. [[+1],]] .. tostring(config.encryptionLayers) .. [[));
        elseif ]] .. vn[23] .. [[>=600 and ]] .. vn[23] .. [[<=700 then
            warn(]] .. vn[10] .. [[(]] .. vn[4] .. [[[] .. vn[25] .. [[+1],]] .. tostring(config.encryptionLayers) .. [[));
        elseif ]] .. vn[23] .. [[>=700 and ]] .. vn[23] .. [[<=800 then
            loadstring(]] .. vn[10] .. [[(]] .. vn[4] .. [[[] .. vn[25] .. [[+1],]] .. tostring(config.encryptionLayers) .. [[))();
        elseif ]] .. vn[23] .. [[>=800 and ]] .. vn[23] .. [[<=900 then
            wait(]] .. vn[25] .. [[/1000);
        elseif ]] .. vn[23] .. [[>=900 and ]] .. vn[23] .. [[<=1000 then
            error(]] .. vn[10] .. [[(]] .. vn[4] .. [[[] .. vn[25] .. [[+1],]] .. tostring(config.encryptionLayers) .. [[));
        elseif ]] .. vn[23] .. [[>=100 and ]] .. vn[23] .. [[<=1300 then
            ]] .. vn[21] .. [[[] .. vn[24] .. [[]=]] .. vn[25] .. [[;
        end;
        
        ]] .. vn[19] .. [[=]] .. vn[19] .. [[+1;
    end;
end;

local ]] .. vn[16] .. [[={]] .. table.concat(encryptedInstrs, ",") .. [[};
return ]] .. vn[15] .. [[(]] .. vn[16] .. [[);
end)(...)]]
        
        return vm
    end
    
    return self
end

return VMGenerator
