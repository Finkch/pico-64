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
        bin ..= num \ 2 ^ i % 2
    end
 
    --	returns
    return bin
end

-- returns a single bit at a specified memory address


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