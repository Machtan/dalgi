local M = {}

local Sprite = {}

function Sprite:new(sheet, id)
    local obj = {
        sheet = sheet,
        id = id,
    }
    self.__index = self
    return setmetatable(obj, self)
end

function Sprite:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    self.sheet:draw(self.id, x, y, r, sx, sy, ox, oy, kx, ky)
end

function Sprite:center()
    return self.sheet:center(self.id)
end

function Sprite:__tostring()
    return "Sprite("..self.id..")"
end

local SpriteSheet = {}

function SpriteSheet:from_image(image)
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

function SpriteSheet:new(filepath)
    local image = love.graphics.newImage(filepath)
    return SpriteSheet:from_image(image)
end

function SpriteSheet:define_sprite(name, x, y, w, h)
    self.sprites[name] = love.graphics.newQuad(x, y, w, h, self.w, self.h)
end

function SpriteSheet:sprite(name)
    if self.sprites[name] == nil then
        error("Unknown sprite '"..name.."'")
    else
        return Sprite:new(self, name)
    end
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