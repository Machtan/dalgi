local M = {}

local SpriteSheet = {}

function SpriteSheet:new(filepath)
    local image = love.graphics.newImage(filepath)
    local w, h = image:getDimensions()
    local obj = {
        image = image, 
        w = w, 
        h = h, 
        sprites = {}
    }
    self.__index = self
    return setmetatable(obj, self)
end

function SpriteSheet:define_sprite(name, x, y, w, h)
    self.sprites[name] = love.graphics.newQuad(x, y, w, h, self.w, self.h)
end

function SpriteSheet:draw(name, x, y, r, sx, sy, ox, oy, kx, ky)
    local quad = self.sprites[name]
    love.graphics.draw(self.image, quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

function SpriteSheet:center(name)
    local quad = self.sprites[name]
    local _, _, w, h = quad:getViewport()
    return w / 2, h / 2
end

M.SpriteSheet = SpriteSheet

return M