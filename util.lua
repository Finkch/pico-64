--	utility functions

--	converts a number to a
--	binary string
--	not my code! found it on
--	the bbs
function to_bin(num)
    --	creates string
    local bin = ""
    
    --	stitches together bitwise
    for i = 7, 0, -1 do
        bin ..= (num >> i) & 1
    end
 
    --	returns
    return bin
end

function to_hex(num, ox)

    if (ox == nil) ox = true

    if num == 0 then
        if (ox) return "0x/"
        return "/"
    end

    -- sets the prefix
    local hex = ""

    hex ..= tostr(num, true)

    if (not ox) hex = sub(hex, 3)

    for i = 0, #hex - 1 do
        if hex[i] == "." then
            hex = sub(hex, 0, i - 1)
            break
        end
    end

    return hex
end



--	prints address, binary value
--	at the address, and
--	unformatted value
function print_peek(addr)
   print(addr..":\t"..to_bin(@addr).." "..@addr)
end

--	prints a word, in binary
function print_word(addr)
    local str = ""
    for i = 0, word_size - 1 do
        str = str.." "..@(addr+i)
    end
    print(str)
end

--	from a starting address,
--	sets the next n consecutive
--	addresses to 0 (clears)
function clear_mem(start, n)
   for i = start, start + n do
       poke(i, 0)
   end
end