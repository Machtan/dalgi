local M = {}

local function i_prettify(item, indent, table_pointers)
    local t = type(item)
    if t == "table" then
        local current_id = table_pointers.next_id
        
        if table_pointers[item] ~= nil then
            return "{ @"..table_pointers[item].." }"
        else
            table_pointers[item] = tostring(current_id)
            table_pointers.next_id = current_id + 1
        end
            
        local meta = getmetatable(item) or {}
        
        if meta.__tostring_with_indent ~= nil then
            return item:__tostring_with_indent(indent)
        elseif meta.__tostring ~= nil then
            return item:__tostring()
        else
            local new_indent = indent + 2
            local oldp = string.rep(" ", indent)
            local newp = string.rep(" ", new_indent)
            local text
            if #item ~= 0 then
                text = "[ &"..tostring(current_id).."\n"
                local pretty_value
                for _, v in ipairs(item) do
                    local pretty = i_prettify(v, new_indent, table_pointers) 
                    text = text .. newp .. pretty .. ",\n"
                end
                text = text .. oldp .. "]"
            else
                local max_key_len = 0
                local keys = {}
                local has_values = false
                for k, _ in pairs(item) do
                    table.insert(keys, k)
                    has_values = true
                end
                if not has_values then
                    return "[]"
                end
                table.sort(keys, function (a, b)
                    return a < b
                end)
                
                local items = {}
                for _, k in ipairs(keys) do
                    local v = item[k]
                    local pretty_key = i_prettify(k, new_indent, table_pointers)
                    local pretty_value = i_prettify(v, new_indent, table_pointers) 
                    items[k] = {pretty_key, pretty_value} 
                    if string.len(pretty_key) > max_key_len then
                        max_key_len = string.len(pretty_key)
                    end
                end
                text = "{ &"..tostring(current_id)
                local pretty_value
                
                for _, k in ipairs(keys) do
                    local pair = items[k]
                    local key_pad = max_key_len - string.len(pair[1])
                    text = text .. "\n" .. newp .. pair[1] .. ": "
                    text = text .. string.rep(" ", key_pad) .. pair[2] .. ","
                end
                text = text .. "\n" .. oldp .. "}"
            end
            return text
        end
    elseif t == "string" then
        return "\"" .. string.gsub(string.gsub(item, "\\", "\\\\"), "\"", "\\\"") .. "\""
    else
        return tostring(item)
    end
end

local function prettify(item)
    return i_prettify(item, 0, {next_id = 1})
end

local function pretty_print(item)
    print(prettify(item))
end

M.prettify = prettify
M.print = pretty_print

return M