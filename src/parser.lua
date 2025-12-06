-- parser.lua
-- Advanced Lua code parser

local Parser = {}

function Parser.new(config)
    local self = {
        config = config,
        tokens = {}
    }
    
    function self.tokenize(code)
        local tokens = {}
        
        -- Extract double-quoted strings
        for str in code:gmatch('"([^"]*)"') do
            table.insert(tokens, {type = "string", value = str, quote = '"'})
        end
        
        -- Extract single-quoted strings
        for str in code:gmatch("'([^']*)'") do
            table.insert(tokens, {type = "string", value = str, quote = "'"})
        end
        
        -- Extract multi-line strings
        for str in code:gmatch("%[%[(.-)%]%]") do
            table.insert(tokens, {type = "string", value = str, quote = "[[]]"})
        end
        
        -- Extract function calls
        for func in code:gmatch("([%w_%.]+)%s*%(") do
            table.insert(tokens, {type = "call", value = func})
        end
        
        -- Extract numbers
        for num in code:gmatch("([%d%.]+)") do
            if tonumber(num) then
                table.insert(tokens, {type = "number", value = tonumber(num)})
            end
        end
        
        -- Extract variables
        for var in code:gmatch("local%s+([%w_]+)") do
            table.insert(tokens, {type = "variable", value = var})
        end
        
        return tokens
    end
    
    function self.parse(code)
        local ast = {
            instructions = {},
            constants = {},
            metadata = {},
            variables = {}
        }
        
        local lines = {}
        for line in code:gmatch("[^\r\n]+") do
            if line:match("%S") then
                table.insert(lines, line)
            end
        end
        
        ast.metadata.lineCount = #lines
        ast.metadata.complexity = math.max(3, math.floor(#code / 50))
        ast.metadata.codeLength = #code
        
        for lineNum, line in ipairs(lines) do
            local instr = self.parseLine(line, lineNum)
            if instr then
                table.insert(ast.instructions, instr)
            end
        end
        
        return ast
    end
    
    function self.parseLine(line, lineNum)
        local instr = {
            type = "nop", 
            args = {}, 
            line = lineNum,
            original = line
        }
        
        -- Print statement
        if line:match("print%s*%(") then
            local str = line:match('["\']([^"\']+)["\']') or line:match("%[%[(.-)%]%]")
            if str then
                instr.type = "print"
                instr.args = {str}
                instr.opcode = math.random(500, 600)
                return instr
            end
        end
        
        -- Warn statement
        if line:match("warn%s*%(") then
            local str = line:match('["\']([^"\']+)["\']') or line:match("%[%[(.-)%]%]")
            if str then
                instr.type = "warn"
                instr.args = {str}
                instr.opcode = math.random(600, 700)
                return instr
            end
        end
        
        -- Loadstring
        if line:match("loadstring%s*%(") then
            local str = line:match('["\']([^"\']+)["\']') or line:match("%[%[(.-)%]%]")
            if str then
                instr.type = "loadstring"
                instr.args = {str}
                instr.opcode = math.random(700, 800)
                return instr
            end
        end
        
        -- Wait/task.wait
        if line:match("wait%s*%(") or line:match("task%.wait%s*%(") then
            local num = line:match("%(([%d%.]+)%)")
            if num then
                instr.type = "wait"
                instr.args = {tonumber(num)}
                instr.opcode = math.random(800, 900)
                return instr
            end
        end
        
        -- Error statement
        if line:match("error%s*%(") then
            local str = line:match('["\']([^"\']+)["\']')
            if str then
                instr.type = "error"
                instr.args = {str}
                instr.opcode = math.random(900, 1000)
                return instr
            end
        end
        
        -- Variable assignment
        if line:match("local%s+([%w_]+)%s*=") then
            local var = line:match("local%s+([%w_]+)")
            instr.type = "assign"
            instr.args = {var}
            instr.opcode = math.random(1000, 1100)
            return instr
        end
        
        -- Function definition
        if line:match("function%s+([%w_]+)") then
            local func = line:match("function%s+([%w_]+)")
            instr.type = "function"
            instr.args = {func}
            instr.opcode = math.random(1100, 1200)
            return instr
        end
        
        -- Generic instruction
        instr.type = "generic"
        instr.opcode = math.random(100, 500)
        
        return instr
    end
    
    function self.extractStrings(code)
        local strings = {}
        
        -- Double quotes
        for str in code:gmatch('"([^"]*)"') do
            table.insert(strings, str)
        end
        
        -- Single quotes
        for str in code:gmatch("'([^']*)'") do
            table.insert(strings, str)
        end
        
        -- Multi-line
        for str in code:gmatch("%[%[(.-)%]%]") do
            table.insert(strings, str)
        end
        
        return strings
    end
    
    return self
end

return Parser
