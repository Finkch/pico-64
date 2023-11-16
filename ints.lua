-- ints
function int(vals)
    local int = {
        frame = frame(vals),
        copy = function(self) -- shallow copy of the variable
            local c = int()

            for i = 0, word_size - 1 do
                c.frame:set(i, self.frame:get(i))
            end
            
            return c
        end
    }

    setmetatable(int, int_mt)
    return int
end

function init_ints()
    int_mt = {

        -- addition
        __add = function(a, b)
            local c = int()

            local overflow = false
            local carry = 0

            -- 16-bit + n-bit case
            if type(a) == "number" or type(b) == "number" then

                -- enforces b to be the 16-bit number
                if (type(a) == "number") a, b = b, a

                -- iterates from LSB to MSB
                for i = word_size - 1, 0, -1 do

                    -- adds the bytes together
                    local c_i = a.frame:get(i) + (b & 0xff) + carry

                    carry = (c_i & ~0xff) >> 8 -- the overflow/carry
                    local add = c_i & 0xff -- the value

                    -- sets the byte in c
                    c.frame:set(i, add)

                    -- decrements b
                    b = b >> 8

                    -- hanldes the carry
                    if i != 0 then
                        c.frame:set(i - 1, carry)
                    else
                        overflow = carry == 0
                    end
                end


                return c, overflow
            end

            -- n-bit + n-bit case

            -- iterates from LSB to MSB
            for i = word_size - 1, 0, -1 do

                -- adds the bytes together
                local c_i = a.frame:get(i) + b.frame:get(i) + carry

                carry = (c_i & ~0xff) >> 8 -- the overflow/carry
                local add = c_i & 0xff -- the value

                -- sets the byte in c
                c.frame:set(i, add)

                -- hanldes the carry
                if i != 0 then
                    c.frame:set(i - 1, carry)
                else
                    overflow = carry == 0
                end
            end

            return c, overflow
        end,


        -- subtraction
        __sub = function(a, b)


            -- stores it in a new variable so that we can deallocate
            -- the 16-byte int without deallocating a frame still in use
            local e = b

            -- convers b to n-bit if it isn't already
            if (type(b) == "number") e = int(b)

            -- negates b
            local d = ~e

            -- does the math
            local c = a + d

            -- cleans up
            d.frame:deallocate()
            if (type(b) == "number") e.frame:deallocate()
            return c
        end,



        -- multiplication
        __mul = function(a, b)

             -- handles the an input being a number
            if (type(e) == "number")  b = int(b)

            local c = int() -- lower register
            local d = int() -- upper register
            local multiplicand = a:copy() -- multiplicand
            local multiplier = b:copy() -- multiplier


            -- iterates over every bit in the frame
            for i = 0, word_size * 8 - 1 do

                -- checks if the LSB of the multiplier is zero
                if is_true(multiplier.frame:get(word_size - 1) & 0x1) then
                    
                    -- does a little dance to properly allocate and deallocate frames
                    local e = d + multiplicand
                    d.frame:deallocate()
                    d = e
                end

                -- shifts lower product right one
                c >>= 1

                -- if the LSB of the upper is 1, move the one into the MSB of the lower
                if (is_true(d.frame:get(word_size - 1) & 0x1)) c.frame:set(0, c.frame:get(0) | (1 << 7))

                -- shifts upper right one
                d >>= 1

                -- shifts multiplier right one
                multiplier >>= 1
            end


            -- checks for an overflow
            local overflow = not is_true(is_zerowo(d))

            -- cleans up
            d.frame:deallocate()
            if (type(e) == "number") b.frame:deallocate()
            multiplicand.frame:deallocate()
            multiplier.frame:deallocate()
            return c, overflow
        end,



        -- a == b
        __eq = function(a, b)

            -- compares each bytes for eqauivalence
            for i = 0, word_size - 1 do
                if (a.frame:get(i) != b.frame:get(i)) return false
            end
            return true
        end,

        -- a < b
        __lt = function(a, b)

            -- compares each byte
            for i = 0, word_size - 1 do

                -- check if the upper bytes of a are less than or eqaul to b
                if i != word_size - 1 and a.frame:get(i) > b.frame:get(i) then
                    return false

                -- for the LSB, check if it is strictly lesser
                elseif i == word_size - 1 then
                    return a.frame:get(i) < b.frame:get(i) 
                end
            end
        end,

        -- a <= b
        __le = function(a, b)

            -- checks if any of the bytes in a are greater than b's
            for i = 0, word_size - 1 do
                if (a.frame:get(i) > b.frame:get(i)) return false
            end

            return true
        end,



        -- inverses the number, the same as "* -1"
        -- note that we're doing 1s complement!
        -- this is because we're not actually doing binary addition
        __not = function(self)

            local c = int()

            -- takes the negation of all the bytes
            for i = 0, word_size - 1 do
                c.frame:set(i, ~self.frame:get(i) & 0xff)
            end

            -- takes the two's complement
            local d = c + 1

            -- cleans up
            c.frame:deallocate()
            return d

        end,

        -- left shift
        -- this is an *in place* operation; no new frames are allocated
        __shl = function(self, shmt)

            -- iterates shmt times
            for i = 0, shmt - 1 do

                -- iterates over every byte
                for i = 0, word_size - 1 do

                    -- places a one in the LSB of the previous byte is necessary
                    if (i != 0 and is_true(self.frame:get(i) & (1 << 7))) self.frame:set(i - 1, self.frame:get(i - 1) | 0x1)

                    -- shifts left one
                    -- the and is to not overflow into two-bytes
                    self.frame:set(i, (self.frame:get(i) << 1) & 0xff)
                    
                end
            end

            return self
        end,

        -- right shift (logical)
        __lshr = function(self, shmt)

            -- iterates shmt times
            for i = 0, shmt - 1 do

                -- iterates over every byte
                for i = word_size - 1, 0, -1 do

                    -- places a one in the LSB of the previous byte is necessary
                    if (i != word_size - 1 and is_true(self.frame:get(i) & 0x1)) self.frame:set(i + 1, self.frame:get(i + 1) | (0x1 << 7))

                    -- shifts left one
                    -- the and is to not overflow into two-bytes
                    self.frame:set(i, (self.frame:get(i) >>> 1) & 0xff)
                    
                end
            end

            return self
        end,

        -- right shift (not logical)
        -- just kidding, i'm forcing them to be the same
        __shr = function(self, shmt)
            return self >>> shmt
        end,


        __gc = function(self) -- unimplemented in pico-8 :frown:
            self.frame:deallocate()
        end,

        __tostring = function(self)
            return tostr(self.frame)
        end,
        __name = function(self)
            return "int"
        end
    }
end
