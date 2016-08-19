local M = {}

local PixelCollider = {}

function PixelCollider:_new_with_area(image, x, y, w, h)
    local data = image:getData()
    local grid = {}
    for gx=0, w-1, 1 do
        local col = {}
        grid[gx] = col
        for gy=0, h-1, 1 do
            local _, _, _, a = data:getPixel(x+gx, y+gy)
            col[gy] = a ~= 0
        end
    end
    
    local obj = {grid = grid}
    self.__index = self
    return setmetatable(obj, self)
end

function PixelCollider:new_with_area(filepath, x, y, w, h)
    return PixelCollider:_new_with_area(love.graphics.newImage(filepath), x, y, w, h)
end

function PixelCollider:new(filepath)
    local image = love.graphics.newImage(filepath)
    local w, h = image:getDimensions()
    return PixelCollider:_new_with_area(image, 0, 0, w, h)
end

function PixelCollider:contains(x, y)
    local col = self.grid[x]
    return col ~= nil and col[y] == true
end

function PixelCollider:contains_at(left, top, x, y)
    local rx = x - left
    local ry = y - top
    return self:contains(rx, ry)
end

M.PixelCollider = PixelCollider
return M