local path = (...)
local prefix = (path and path.."." or "")

local M = {}
local include = {
    "common", 
    "rect", 
    "animation",
    "spritesheet",
    "pretty_print",
    "pixel_collider",
    "safe_ffi_dlopen",
}

for _, modname in ipairs(include) do
    local mod = require(prefix .. modname)
    for k, v in pairs(mod) do
        M[k] = v
    end
end

local submodules = {
}

for _, modname in ipairs(submodules) do
    M[modname] = require(prefix .. modname)
end

return M