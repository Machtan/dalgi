local M = {}
local submodules = {
    "common", 
    "rect", 
    "animation",
    "spritesheet",
    "pretty_print",
}

for _, modname in pairs(submodules) do
    local mod = require(modname)
    for k, v in pairs(mod) do
        M[k] = v
    end
end

return M