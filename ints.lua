-- ints
function int(vals)
    local int = {
        frame = frame(vals)
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

            -- convers b to n-bit if it isn't already
            if (type(b) == "number") b = int(b)

            -- negates b
            local d = ~b

            -- does the math
            local c = a + d

            -- cleans up
            d.frame:deallocate()
            return c
        end,



        -- inverses the number, the same as "* -1"
        -- note that we're doing 1s complement!
        -- this is because we're not actually doing binary addition
        __not = function(self)

            local c = int()

            -- takes the negation of all the bytes
            for i = 0, word_size - 1 do
                poby(c.frame.addr + i, ~peby(self.frame.addr + i) & 0xff)
            end

            -- takes the two's complement
            d = c + 1

            -- cleans up
            c.frame:deallocate()
            return d

        end,
        __tostring = function(self)
            return tostr(self.frame)
        end,
        __name = function(self)
            return "int"
        end
    }
end
