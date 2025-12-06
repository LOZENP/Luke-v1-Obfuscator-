-- encoder.lua
-- Encryption and encoding module

local Utils = require("src.utils")

local Encoder = {}

function Encoder.new(config)
    local self = {
        config = config,
        primaryKey = Utils.generateKey(256),
        secondaryKey = Utils.generateKey(128),
        stringKey = Utils.generateKey(64),
        tertiaryKey = Utils.generateKey(32)
    }
    
    function self.encryptByte(byte, key, index)
        local k = key[((index - 1) % #key) + 1]
        return Utils.xorByte(byte, k)
    end
    
    function self.encryptString(str, layers)
        layers = layers or 1
        local encrypted = {}
        
        for i = 1, #str do
            local byte = string.byte(str, i)
            local encByte = byte
            
            -- Layer 1: String key
            encByte = self.encryptByte(encByte, self.stringKey, i)
            
            -- Layer 2: Secondary key
            if layers >= 2 then
                encByte = self.encryptByte(encByte, self.secondaryKey, i)
            end
            
            -- Layer 3: Tertiary key with offset
            if layers >= 3 then
                encByte = self.encryptByte(encByte, self.tertiaryKey, i + #str)
            end
            
            table.insert(encrypted, encByte)
        end
        
        return encrypted
    end
    
    function self.encryptInstruction(instr, index)
        local encrypted = {}
        for i, val in ipairs(instr) do
            encrypted[i] = self.encryptByte(val, self.primaryKey, index + i - 1)
        end
        return encrypted
    end
    
    function self.rotateKeys()
        -- Rotate keys for additional security
        local temp = self.primaryKey[1]
        for i = 1, #self.primaryKey - 1 do
            self.primaryKey[i] = self.primaryKey[i + 1]
        end
        self.primaryKey[#self.primaryKey] = temp
    end
    
    function self.getKeyStrings()
        return {
            primary = table.concat(self.primaryKey, ","),
            secondary = table.concat(self.secondaryKey, ","),
            string = table.concat(self.stringKey, ","),
            tertiary = table.concat(self.tertiaryKey, ",")
        }
    end
    
    function self.encryptNumber(num)
        -- Encode numbers to prevent easy detection
        local str = tostring(num)
        return self.encryptString(str, 1)
    end
    
    return self
end

return Encoder
