--	utility functions

--	converts a number to a
--	binary string
--	not my code! found it on
--	the bbs
function to_bin(num)
    --	creates string
    local bin=""
    
    --	stitches together bitwise
 for i=7,0,-1 do
   bin..=num\2^i %2
 end
 
 --	returns
 return bin
end


--	prints address, binary value
--	at the address, and
--	unformatted value
function print_peek(addr)
   print(addr..":\t"..to_bin(@addr).." "..@addr)
end

--	prints a word, in binary
function print_word(addr)
   local str=""
   for i=0,b-1 do
    str=str.." "..@(addr+i)
   end
   print(str)
end

--	from a starting address,
--	sets the next n consecutive
--	addresses to 0 (clears)
function clear_mem(start,n)
   for i=start,start+n do
       poke(i,0)
   end
end


--	given number, converrt it
--	to scientific notation
function f_to_sci(fl)

   --	if zero, send back zero
   if (fl==0) return 0,0
   
   --	creates the exponent
   local e=0
   
   
   --	if the lead is too big,
   --	shrinks the number until
   -- coefficient is smaller than
   --	10
   while abs(fl)>=10 do
       fl/=10
       e+=1
   end
   
   --	if the lead is too small,
   --	stretches the number until
   --	coefficient is greater than
   --	1
   while abs(fl)<1 do
       fl*=10
       e-=1
   end
   
   --	returns formatted numbers
   return fl,e
end


--	given scientific notaiton,
--	converts to binary
--	scientific notaiton
function e_to_p(fl,e)
   if (fl==0) return 0,0

   --	the binary exponent
   local p=0
   
   --	if the e exponent is +
   while e>0 or abs(fl)>10 do
   
       --	shrinks the e exponent
       if abs(fl)<=10 then
           fl*=10
           e-=1
       end
       
       --	stretches p exponent
       fl/=2
       p+=1
   end
   
   --	if the e exponent is -
   while e<0 or abs(fl)<1 do
       -- stretches the e exponent 
       if abs(fl)>1 then
           fl/=10
           e+=1
       end
       
       --	shrinks the p exponent
       fl*=2
       p-=1
   end
   
   --	returns formatted numbers
   return fl,p
end

--	converts binary scientific
--	to regular scientific
function p_to_e(fl,p)
   if (fl==0) return 0,0

   --	creates exponent
   local e=0
   
   --	if the p exponent is +
   while p>0 do
       --	shrinks p exponent	
       fl*=2
       p-=1
       
       --	stretches e exponent
       if abs(fl)>=10 then
           fl/=10
           e+=1
       end
   end
   
   --	if the p exponent is -
   while p<0 do
       --	stretches p exponent
       fl/=2
       p+=1
       
       --	shrinks e exponent
       if abs(fl)<1 then
           fl*=10
           e-=1
       end
   end
   
   --	returns formatted numbers
   return fl,e
end
