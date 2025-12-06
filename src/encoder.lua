-- encoder.lua (HARDENED VERSION)
-- Advanced multi-layer encryption with dynamic keys

local Utils = require("src.utils")

local Encoder = {}

function Encoder.new(config)
    local self = {
        config = config,
        primaryKey = Utils.generateKey(256),
        secondaryKey = Utils.generateKey(128),
        stringKey = Utils.generateKey(64),
        tertiaryKey = Utils.generateKey(32),
        saltKey = Utils.generateKey(16)
    }
    
    -- Advanced XOR with bit rotation
    function self.advancedXor(byte, key, index, salt)
        local result = Utils.xorByte(byte, key)
        -- Add rotation based on index
        local rotation = (index % 8)
        result = ((result << rotation) | (result >> (8 - rotation))) & 0xFF
        -- Add salt mixing
        result = Utils.xorByte(result, salt)
        return result
    end
    
    -- String chunking to break patterns
    function self.chunkString(str, chunkSize)
        local chunks = {}
        for i = 1, #str, chunkSize do
            table.insert(chunks, str:sub(i, i + chunkSize - 1))
        end
        return chunks
    end
    
    -- Encrypt with multiple algorithms
    function self.encryptString(str, layers)
        layers = layers or 1
        
        -- Split string into random-sized chunks
        local chunkSize = math.random(3, 8)
        local chunks = self.chunkString(str, chunkSize)
        local encrypted = {}
        
        for chunkIdx, chunk in ipairs(chunks) do
            local chunkEncrypted = {}
            
            for i = 1, #chunk do
                local byte = string.byte(chunk, i)
                local globalIndex = (chunkIdx - 1) * chunkSize + i
                local encByte = byte
                
                -- Layer 1: Advanced XOR with rotation
                local salt1 = self.saltKey[((globalIndex - 1) % #self.saltKey) + 1]
                encByte = self.advancedXor(encByte, self.stringKey[((globalIndex - 1) % #self.stringKey) + 1], globalIndex, salt1)
                
                -- Layer 2: Secondary key with reverse index
                if layers >= 2 then
                    local reverseIdx = #str - globalIndex + 1
                    local salt2 = self.saltKey[((reverseIdx - 1) % #self.saltKey) + 1]
                    encByte = self.advancedXor(encByte, self.secondaryKey[((reverseIdx - 1) % #self.secondaryKey) + 1], reverseIdx, salt2)
                end
                
                -- Layer 3: Tertiary with chunk mixing
                if layers >= 3 then
                    local mixIdx = (globalIndex * chunkIdx) % 256
                    encByte = Utils.xorByte(encByte, self.tertiaryKey[((mixIdx - 1) % #self.tertiaryKey) + 1])
                    -- Add extra obfuscation
                    encByte = (encByte + chunkIdx) % 256
                end
                
                table.insert(chunkEncrypted, encByte)
            end
            
            -- Store chunk with metadata
            table.insert(encrypted, {
                data = chunkEncrypted,
                size = #chunk,
                index = chunkIdx
            })
        end
        
        return encrypted
    end
    
    -- Encrypt instruction with dynamic mixing
    function self.encryptInstruction(instr, index)
        local encrypted = {}
        local mixer = (index * 7 + 13) % 256 -- Dynamic mixer
        
        for i, val in ipairs(instr) do
            -- Multiple XOR layers with mixing
            local enc = Utils.xorByte(val, self.primaryKey[((index - 1) % #self.primaryKey) + 1])
            enc = Utils.xorByte(enc, mixer)
            enc = (enc + index) % 256 -- Add index-based offset
            encrypted[i] = enc
        end
        
        return encrypted
    end
    
    function self.getKeyStrings()
        return {
            primary = table.concat(self.primaryKey, ","),
            secondary = table.concat(self.secondaryKey, ","),
            string = table.concat(self.stringKey, ","),
            tertiary = table.concat(self.tertiaryKey, ","),
            salt = table.concat(self.saltKey, ",")
        }
    end
    
    -- Generate fake keys for misdirection
    function self.generateFakeKeys(count)
        local fakeKeys = {}
        for i = 1, count do
            fakeKeys[i] = table.concat(Utils.generateKey(math.random(32, 128)), ",")
        end
        return fakeKeys
    end
    
    return self
end

return Encoder
