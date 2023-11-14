-- ints
function int(vals)
    local int = {frame = frame(vals)}

    setmetatable(int, int_mt)
    return int
end

function init_ints()
    int_mt = {
        __add = function(a, b)
            c = int()

            local carry = 0
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
                    assert(carry == 0, "overflow during addition: "..tostr(carry)..", "..(a.frame:get(i) + b.frame:get(i) + carry))
                end
            end

            return c
        end,
        __tostring = function(self)
            return tostr(self.frame)
        end,
        __name = function(self)
            return "int"
        end
    }
end
