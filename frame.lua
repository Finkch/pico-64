-- creates a frame
function frame(value, addr)
    
    -- holds the relevant data
    frame_num, addr = allocate(addr)
    local f = {
        frame_num = frame_num, -- the frame number
        addr = addr, -- absolute address
        deallocate = function(self) -- a function to deallocate the frame
            deallocate(self.frame_num)
        end,
        set = function(self, value, index)
            poby(index, value)
        end
    }

    -- sets default values
    if type(value) == "table" then
        powo(addr, value)
    elseif type(value) == "number" then
        poby(addr, value)
    end

    -- assigns the metatable
    setmetatable(f, frame_mt)

    return f
end

-- sets up metatable
function init_frames()
    frame_mt = {
        __tostring = function(self)
            local str = ""
            for i = 0, word_size - 1 do
                str = str..to_hex(@(self.addr + i), i == 0) -- prints in hex (pico-8 readout it small)
            end
            return str
        end
    }
end