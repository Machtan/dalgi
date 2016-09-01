
local function hash_object(obj)
    return type(obj) .. "." .. tostring(obj)
end

local EntityGroup = {}

local LISTENERS = {
    "init",
    "destroy",
    "update",
    "keypressed",
    "keyreleased",
    "mousepressed",
    "mousereleased",
    "mousemoved",
    "textinput",
    "wheelmoved",
    "filedropped",
    "directorydropped",
    "quit",
}
-- Objects are drawn in the order from the lowest numbering layer to the highest
local DEFAULT_DRAW_LAYER = 1
function EntityGroup:new(x, y)
    self.__index = self
    local _listeners = {}
    for _, category in ipairs(LISTENERS) do
        _listeners[category] = {}
    end
    local _drawables = {}
    return setmetatable({
        x = x or 0,
        y = y or 0,
        _listeners = _listeners,
        _tags = {},
        _drawables = {},
        _entities = {},
        _tagged = {},
        _layers = { DEFAULT_DRAW_LAYER },
    }, self)
end

function EntityGroup:init()
    for _, listener in ipairs(self._listeners.init) do
        listener:init(self)
    end
end

function EntityGroup:add(entity, o_draw_layer)
    local hash = hash_object(entity)
    assert(self._entities[hash] == nil, "Entity to group twice")
    if entity.draw then
        if not o_draw_layer then
            o_draw_layer = DEFAULT_DRAW_LAYER
        end
        if self._drawables[o_draw_layer] == nil then
            self._drawables[o_draw_layer] = {}
            table.insert(self._layers, o_draw_layer)
            table.sort(self._layers)
        end
        table.insert(self._drawables[o_draw_layer], entity)
    end
            
    for category, entities in pairs(self._listeners) do
        if entity[category] ~= nil then
            table.insert(entities, entity)
        end
    end
    self._entities[hash] = entity
end

-- Removes the object with the given Id but does not run its destructor
function EntityGroup:remove(entity)
    local hash = hash_object(entity)
    assert(self._entities[hash], "Removed entity not in group")
    for tag, entities in pairs(self._tagged) do
        for i, ent in ipairs(entities) do
            if ent == entity then
                table.remove(entities, i)
                break
            end
        end
    end
    
    if entity.draw then
        for _, layer in ipairs(self._drawables) do
            for i, ent in ipairs(layer) do
                if ent == entity then
                    table.remove(layer, i)
                    break
                end
            end
        end
    end
    
    for _, category in ipairs(_listeners) do
        if entity[category] ~= nil then
            for i, ent in ipairs(self._listeners[category]) do
                if ent == entity then
                    table.remove(self._listeners[category], i)
                    break
                end
            end
        end
    end
    self._entities[hash] = nil
end

function EntityGroup:destroy(entity)
    local hash = hash_object(entity)
    assert(self._entities[hash], "Destroyed entity not in group")
    entity.destroy()
    self:remove(entity)
end

function EntityGroup:add_tags(entity, ...)
    local hash = hash_object(entity)
    assert(self._entities[hash], "Tagged entity not in group")
    for tag in ... do
        if self._tagged[tag] == nil then
            self._tagged[tag] = {}
        end
        table.insert(self._tagged[tag], entity)
    end
end

function EntityGroup:find_all_with_tag(tag)
    local tagged = self._tagged[tag]
    assert(tagged, "Tag '"..tag.."' not found")
    return tagged
end

function EntityGroup:remove_tags(entity, ...)
    local hash = hash_object(entity)
    assert(self._entities[hash], "Tagged entity not in group")
    for tag in ... do
        local entities = self._tagged[tag]
        assert(entities, "Tag '"..tag.."' not found")
        for i, ent in ipairs(entities) do
            if ent == entity then
                table.remove(entities, i)
                break
            end
        end
    end
end

function EntityGroup:overwrite_active_love_game()
    for i, name in ipairs(LISTENERS) do
        love[name] = function(...)
            return self[name](self, ...) 
        end
    end
    
    love.draw = function()
        self:draw(0, 0)
    end
end

--------------- LISTENERS ----------------

function EntityGroup:update(delta_time)
    for _, listener in ipairs(self._listeners.update) do
        listener:update(delta_time)
    end
end

function EntityGroup:draw(ox, oy)
    local ox = self.x + (ox or 0)
    local oy = self.y + (oy or 0)
    for _, layer in ipairs(self._layers) do
        for _, entity in ipairs(self._drawables[layer]) do
            entity:draw(ox, oy)
        end
    end
end

function EntityGroup:keypressed(key, scancode, is_repeat)
    for _, entity in ipairs(self._listeners.keypressed) do
        entity:keypressed(key, scancode, is_repeat)
    end
end

function EntityGroup:keyreleased( key, scancode )
    for _, entity in ipairs(self._listeners.keyreleased) do
        entity:keyreleased(key, scancode)
    end
end

function EntityGroup:mousemoved( x, y, dx, dy )
    for _, entity in ipairs(self._listeners.mousemoved) do
        entity:mousemoved(x, y, dx, dy)
    end
end

function EntityGroup:mousepressed( x, y, button, is_touch)
    for _, entity in ipairs(self._listeners.mousepressed) do
        entity:mousepressed(x, y, button, is_touch)
    end
end

function EntityGroup:mousereleased( x, y, button, is_touch)
    for _, entity in ipairs(self._listeners.mousereleased) do
        entity:mousereleased(x, y, button, is_touch)
    end
end

--function EntityGroup:textedited( text, start, length )
--end

function EntityGroup:textinput( text )
    for _, entity in ipairs(self._listeners.textinput) do
        entity:textinput(text)
    end
end

function EntityGroup:wheelmoved( x, y )
    for _, entity in ipairs(self._listeners.wheelmoved) do
        entity:wheelmoved(x, y)
    end
end

function EntityGroup:directorydropped( path )
    for _, entity in ipairs(self._listeners.directorydropped) do
        entity:directorydropped(path)
    end
end

function EntityGroup:filedropped(file_obj)
    for _, entity in ipairs(self._listeners.filedropped) do
        entity:filedropped(file_obj)
    end
end

function EntityGroup:quit()
    -- This might fuck things up if you do destructive things on quit, that
    -- are then interrupted by another handler, so DONT
    for _, entity in ipairs(self._listeners.quit) do
        local abort = entity:quit()
        if abort then
            return true
        end
    end
end

return {
    EntityGroup = EntityGroup,
}