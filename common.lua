local M = {}

local Array = {}

function Array:new()
    local obj = {}
    self.__index = self
    return setmetatable(obj, self)
end

function Array:from(table)
    return setmetatable(table, {__index = self})
end

function Array:push(value)
    table.insert(self, value)
end

function Array:insert(pos, value)
    table.insert(self, pos, value)
end

function Array:append(other)
    for _, v in ipairs(other) do
        self:push(v)
    end
end

function Array:clone()
    local clone = Array:new()
    clone:append(self)
    return clone
end

function Array:join(sep)
    return table.concat(self, sep)
end

function Array:remove(pos)
    return table.remove(self, pos)
end

function Array:remove_item(item)
    for i, v in ipairs(self) do
        if v == item then
            self:remove(i)
            break
        end
    end
end

function Array:pop()
    return table.remove(self)
end

function Array:sort()
    return table.sort(self)
end

function Array:sort_with(cmp)
    return table.sort(self, cmp)
end

M.Array = Array

return M