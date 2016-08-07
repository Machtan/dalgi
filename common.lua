local M = {}

local Table = {}

function Table:new()
    return setmetatable({}, {__index = table})
end

function Table:from(regular_table)
    return setmetatable(regular_table, {__index = table})
end

M.Table = Table

return M