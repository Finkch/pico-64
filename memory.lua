--	memory management
--	starts at 0x4300
--	ends at			0x5e00
--	6912 bytes

--	numbers are signed 16-bit
--	so 2^15-1 is the largest
--	that's 32767

-- 32 bit system
--	first 24 (3) is precision
--	last 8 (1) is the 10^power


function init_memory(b,e)
	be=b-e
	s=4
	
	mtotal=6912 --	total memory
	
	--	upper limit bit map size
	bmap=mtotal/b/8+2*b
	
	--	frame/bitmap size
	f=flr((mtotal-bmap)/b)
	
	--	tracks available frames
	f_available=f
	
	--	start of float memory
	mstart=mtotal-f*b
	
	--	offset of user memory
	offset=0x4300
	
	--	actual memory start
	ms=offset+mstart

	--	memory end
	me=0x5e00
end


--	allocates a frame as occupied
--	returns the frame's index
function allocate()
	
	--	gets the index of the 
	--	first available frame
	local faf=get_faf()
	
	--	throws error if there's no
	--	memory available
	assert(faf, "can't find frame")
		
	--	toggles the bitmap
	toggle_bmap(faf)
	
	--	decrements frames
	f_available-=1
	
	--	checks if out of frames
	assert(f_available>=0, "out of memory")
	
	--	clears the frame
	clear_mem(ms+faf*8,b)
	
	--	returns the frame's index
	return faf
end

--	searches through the bitmap
--	for the first instance of an
--	empty frame, i.e. a zero
function get_faf()
	for i=0,bmap do	--	all bytes
		for j=0,7 do	--	bit in btye
			--	checks if bit is 0
			if @(offset+i)&(1<<j)==0 then
				return 8*i+j	--	returns idx
			end
		end
	end
end

--	deallocates a frame, i.e.
--	sets the value at the index
--	in the bitmap to a zero
function deallocate(frame)
		--	throws error if the frame
		--	is already empty
		assert(f_bmap(frame)==1,"cannot deallocate empty frame ")
		
		--	sets the bitmap
		toggle_bmap(frame)
		
		--	increments frames
		f_available+=1
		
		--	throws error if there is
		--	is somehow too many frames
		assert(f_available<=f, "frame deallocation error")
end

--	toggles the bitmap value
function toggle_bmap(idx)
	--	gets the address
	local ma=offset+flr(idx/8)
	
	--	pokes the bit in question
	poke(ma,@ma^^(1<<(idx%8)))
end

--	checks the state of a flag
function f_bmap(idx)
	--	gets the address
	local ma=offset+flr(idx/8)
	
	--	shifts right so the important
	--	bit is the first one, and
	--	then masks all upper bits
	return (@ma>>(idx%8))&1
end

--	virtual poke
--	pokes up to 1 byte
--	i know that's obvious,
--	but i have to say it again
function po(fl,o,v)
	if (not o) o=0	--	set offset
	c_access(o)	--	checks access
	assert(v<256,"overflow error")
	poke(ms+fl.addr+o,v)	--	pokes
end

function po2(fl,o,v)
	if (not o) o=0
	c_access(o)
	assert(v<0x5999,"overflow error")
	poke2(ms+fl.addr+o,v)
end

--	virtual peek
function pe(fl,o)
	if (not o) o=0	--	set offet
	c_access(o)	--	checks access
	return @(ms+fl.addr+o)	--	peeks
end

function pe2(fl,o)
	if (not o) o=0
	c_access(o)
	return %(ms+fl.addr+o)
end

--	flips a single bit
function bit_flip(fl,boff)
	if (not boff) boff=0
	local byte=boff\8
	c_access(byte)
	
	--assert(false,fl.addr+byte..": "..to_bin(pe(fl,byte)).." "..to_bin((1<<(boff%8))).." "..to_bin(pe(fl,byte)^^(1<<(boff%8))))
	poke(ms+fl.addr+byte,pe(fl,byte)^^(1<<(boff%8)))
end


--	ensures memory accesses
--	are legal accesses
function c_access(o)
	assert(o<b,"illegal access right ("..o..")")
	assert(o>=0,"illegal access left")
end

--	debug prinout
function draw_memory()
	print("bytes: "..b.."\texponent: "..e)
	print("mtotal:\t"..mtotal)
	print("frames:\t"..f_available)
	print("f:\t\t"..f)
	print("bmap:\t"..bmap.." => "..bmap*8)
	print("mstart:\t"..mstart)
	print(offset.." "..ms.."-"..me)
end
