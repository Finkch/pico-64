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
        set = function(self, index, value) -- pokes a byte
            c_access(index)
            poby(self.addr + index, value)
        end,
        get = function(self, index) -- gets a byte in the word
            c_access(index)
            return peby(self.addr + index)
        end,
        word = function(self) -- returns the word at the frame's address
            return pewo(self.addr)
        end
    }

    -- sets default values
    if type(value) == "table" then
        powo(addr, value)
    elseif type(value) == "number" then
        poby(addr + word_size - 1, value) -- poke to the LSB
    end

    -- assigns the metatable
    setmetatable(f, frame_mt)

    return f
end

-- sets up metatable
function init_frames()
    frame_mt = {
        __tostring = function(self)
            return to_hexes(self:word())
        end
    }
end
