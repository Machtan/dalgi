local M = {}

-- Animation class
local Animation = {}

function Animation:new(manager, id)
    local instance = {
        manager = manager,
        id = id,
    }
    self.__index = self
    return setmetatable(instance, self)
end

-- options: {loop, speed_factor, start_at_frame, elapsed}
function Animation:play(options)
    self.manager:play(self.id, options)
end

function Animation:pause()
    self.manager:pause(self.id)
end

function Animation:resume()
    self.manager:resume(self.id)
end 

function Animation:stop()
    self.manager:stop(self.id)
end

function Animation:go_to_frame(number)
    self.manager:go_to_frame(self.id, number)
end

function Animation:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    self.manager:draw(self.id, x, y, r, sx, sy, ox, oy, kx, ky)
end

function Animation:center()
    local quad = self.animation.frames[1]
    local _, _, w, h = quad:getViewport()
    return w / 2, h / 2
end


-- AnimationManager class
local AnimationManager = {}

function AnimationManager:new()
    local instance = {
        images = {},
        animations = {},
        instances = {},
        next_id = 1,
    }
    self.__index = self
    return setmetatable(instance, self)
end

function AnimationManager:define_animation(name, filepath, x, y, w, h, frame_count, duration)
    assert(self.animations[name] == nil, 
        "Animation '"..name.."' already defined")
    local image, iw, ih
    local image_table = self.images[filepath]
    if image_table ~= nil then
        image, iw, ih = unpack(image_table)
    else
        image = love.graphics.newImage(filepath)
        iw, ih = image:getDimensions()
        self.images[filepath] = {image, iw, ih}
        print("Loading image")
    end
    local durations = {}
    for i = 1, frame_count, 1 do
        durations[i] = duration / frame_count
    end
    local frames = {}
    for i = 1, frame_count, 1 do
        local x = (x + (i - 1) * w) % iw
        local y = y + math.floor((x + (i - 1) * w) / iw) % ih
        local frame = love.graphics.newQuad(x, y, w, h, iw, ih)
        frames[i] = frame
    end
    self.animations[name] = {image = image, frames = frames, durations = durations}
end

function AnimationManager:set_frame_durations(animation_name, durations)
    assert(self.animations[animation_name] ~= nil, 
        "Animation '"..animation_name.."' not found")
    local animation = self.animations[animation_name]
    assert(#durations == #animation.durations, 
        "The animation is "..tostring(#animation.durations).." frames long, but "
        ..tostring(#durations).." durations were given")
    animation.durations = durations
end

function AnimationManager:instantiate(animation_name)
    assert(self.animations[animation_name] ~= nil, 
        "Animation '"..animation_name.."' not found")
    local id = self.next_id
    self.next_id = self.next_id + 1
    local animation = self.animations[animation_name]
    local duration = animation.durations[start_at_frame]
    local instance = {
        animation = animation,
        is_playing = false,
        is_looping = false,
        speed_factor = 1,
        elapsed = 0,
        current_frame = 1,
        duration = duration,
    }
    self.instances[id] = instance
    return Animation:new(self, id)
end

function AnimationManager:update(delta_time)
    for _, instance in ipairs(self.instances) do
        if instance.is_playing then
            local elapsed = instance.elapsed + delta_time * instance.speed_factor
            -- Check for frames going forward
            while elapsed > instance.duration do
                elapsed = elapsed - instance.duration
                instance.current_frame = instance.current_frame + 1
                if instance.current_frame == #instance.animation.frames + 1 then
                    if not instance.is_looping then
                        instance.current_frame = #instance.animation.frames
                        instance.is_playing = false
                        instance.elapsed = 0
                        break
                    else
                        instance.current_frame = 1
                    end
                else
                    instance.duration = instance.animation.durations[instance.current_frame]
                end
            end
            -- Check for frames going back
            while elapsed < -instance.duration do
                elapsed = elapsed + instance.duration
                instance.current_frame = instance.current_frame - 1
                if instance.current_frame == 0 then
                    if not instance.is_looping then
                        instance.current_frame = 1
                        instance.is_playing = false
                        instance.elapsed = 0
                        break
                    else
                        instance.current_frame = #instance.animation.frames
                    end
                else
                    instance.duration = instance.animation.durations[instance.current_frame]
                end
            end
            instance.elapsed = elapsed
        end
    end
end

function AnimationManager:draw(instance_id, x, y, r, sx, sy, ox, oy, kx, ky)
    local instance = assert(self.instances[instance_id])
    local quad = instance.animation.frames[instance.current_frame]
    love.graphics.draw(instance.animation.image, quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

-- options: {loop, speed_factor, start_at_frame, elapsed}
function AnimationManager:play(instance_id, options)
    instance = assert(self.instances[instance_id])
    instance.is_playing = true
    if options then
        instance.is_looping = options.loop or false
        instance.speed_factor = options.speed_factor or 1
        instance.current_frame = options.start_at_frame or 1
        instance.elapsed = options.elapsed or 0
    end
    instance.duration = instance.animation.durations[instance.current_frame]
end

function AnimationManager:pause(instance_id)
    instance = assert(self.instances[instance_id])
    instance.is_playing = false
end

function AnimationManager:resume(instance_id)
    instance = assert(self.instances[instance_id])
    instance.is_playing = true
    instance.duration = instance.animation.duration[instance.current_frame]
end

function AnimationManager:stop(instance_id)
    instance = assert(self.instances[instance_id])
    instance.is_playing = false
    instance.current_frame = 1
    instance.elapsed = 0
end

function AnimationManager:go_to_frame(instance_id, number)
    instance = assert(self.instances[instance_id])
    instance.current_frame = number
end

M.AnimationManager = AnimationManager

return M