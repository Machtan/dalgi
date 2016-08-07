local M = {}

local Rect = {}

function Rect:new(x, y, width, height)
    local instance = {x = x, y = y, width = width, height = height}
    self.__index = self
    return setmetatable(instance, self)
end

function Rect:from_center(cx, cy, width, height)
    local x = cx - width / 2
    local y = cy - height / 2
    return Rect:new(x, y, width, height)
end

function Rect:clone()
    return Rect:new(self.x, self.y, self.width, self.height)
end

function Rect:move_to(x, y)
    self.x = x
    self.y = y
end

function Rect:moved_to(x, y)
    local instance = self:clone()
    instance.move_to(x, y)
    return instance
end

function Rect:move_by(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Rect:moved_by(dx, dy)
    local instance = self:clone()
    instance.move_by(dx, dy)
    return instance
end

function Rect:center_on(x, y)
    self.x = x - (self.width / 2)
    self.y = y - (self.height / 2)
end

function Rect:centered_on(x, y)
    local instance = self:clone()
    instance:center_on(x, y)
    return instance
end

function Rect:resize(width, height)
    self.width = width
    self.height = height
end

function Rect:resized(width, height)
    Rect:new(self.x, self.y, width, height)
end

function Rect:intersects(other_rect)
    return self:right() > other_rect:left() and self:left() < other_rect:right() and self:top() < other_rect:bottom() and self:bottom() > other_rect:top()
end

function Rect:contains(point)
    local x, y = point
    return x > self.x and x < self:right() and y > self.y and y < self:bottom()
end

function Rect:distance_to_rect(other_rect)
    if self:intersects(other_rect) then
        return nil
    end
    local cx, cy = self:center()
    local ocx, ocy = other_rect:center()
    local x_dist
    if cx < ocx then
        -- [s] [o]
        x_dist = other_rect:left() - self:right()
    else
        -- [o] [s]
        x_dist = self:left() - other_rect:right()
    end
    local y_dist
    if cy < ocy then
        y_dist = other_rect:top() - self:bottom()
    else
        y_dist = self:top() - other_rect:bottom()
    end
    return x_dist, y_dist
end

function Rect:horizontal_distance(x)
    if x >= self:right() then
        return x - self:right()
    elseif x <= self:left() then
        return self:left() - x
    else
        return nil
    end
end

function Rect:vertical_distance(y)
    if y <= self:top() then
        return self:top() - y
    elseif y >= self:bottom() then
        return y - self:bottom()
    else
        return nil
    end
end

function Rect:overlap_size(other_rect)
    if not self:intersects(other_rect) then
        return nil
    end
    local cx, cy = self:center()
    local ocx, ocy = other_rect:center()
    local x_overlap
    if cx < ocx then
        -- [s] [o]
        x_overlap = self:right() - other_rect:left()
    else
        -- [o] [s]
        x_overlap = other_rect:right() - self:left()
    end
    local y_overlap
    if cy < ocy then
        y_overlap = self:bottom() - other_rect:top()
    else
        y_overlap = other_rect:bottom() - self:top()
    end
    return x_overlap, y_overlap
end

function Rect:overlap_width(other_rect)
    if not self:intersects(other_rect) then
        return nil
    end
    local cx, _ = self:center()
    local ocx, _ = other_rect:center()
    local x_overlap
    if cx < ocx then
        -- [s] [o]
        x_overlap = self:right() - other_rect:left()
    else
        -- [o] [s]
        x_overlap = other_rect:right() - self:left()
    end
    return x_overlap
end

function Rect:overlap_height(other_rect)
    if not self:intersects(other_rect) then
        return nil
    end
    local _, cy = self:center()
    local _, ocy = other_rect:center()
    local y_overlap
    if cy < ocy then
        y_overlap = self:bottom() - other_rect:top()
    else
        y_overlap = other_rect:bottom() - self:top()
    end
    return y_overlap
end

function Rect:size()
    return self.width, self.height
end

function Rect:pos()
    return self.x, self.y
end

function Rect:center()
    return self.x + (self.width / 2), self.y + (self.height / 2)
end

function Rect:top()
    return self.y
end

function Rect:set_top(y)
    self.y = y
end

function Rect:bottom()
    return self.y + self.height
end

function Rect:set_bottom(y)
    self.y = y - self.height
end

function Rect:left()
    return self.x
end

function Rect:set_left(x)
    self.x = x
end

function Rect:right()
    return self.x + self.width
end

function Rect:set_right(x)
    self.x = x - self.width
end

function Rect:top_left()
    return self:pos()
end

function Rect:bottom_left()
    return self:left(), self:right()
end

function Rect:top_right()
    return self:right(), self:top()
end

function Rect:bottom_right()
    return self:right(), self:bottom()
end

M.Rect = Rect

return M