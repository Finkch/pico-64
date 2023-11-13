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


function init_memory(word_size)
	
	moffset = 0x4300 --	offset to user memory
	mtotal=6912 --	total memory length (bytes)
	
	--	upper limit bit map size
	bmap = mtotal / word_size / 8 + 2 * word_size
	
	--	number of frames
	frms = flr((mtotal - bmap) / word_size)
	
	--	tracks available frames
	f_available = frms
	
    bmap_end = mtotal - frms * word_size

	--	start of float memory
	mstart = moffset + bmap_end

	--	memory end
	mend = 0x5e00
end


--	allocates a frame as occupied
--	returns the frame's index
function allocate(fnum)

	--	gets the index of the 
	--	first available frame
    if (fnan == nil) local faf=get_faf()
	
	--	throws error if there's no
	--	memory available
	assert(faf, "can't find frame")

    -- ensures frame is empty
    --assert(faf)
		
	--	toggles the bitmap
	toggle_bmap(faf)
	
	--	decrements frames
	f_available -= 1
	
	--	checks if out of frames
	assert(f_available >= 0, "out of memory")
	
	--	clears the frame
	clear_mem(mstartr + faf * 8, word_size)
	
	--	returns the frame's index
	return faf
end

--	searches through the bitmap
--	for the first instance of an
--	empty frame, i.e. a zero
function get_faf()
	for i = 0, bmap do	--	all bytes
		for j = 0, 7 do	--	bit in btye
			--	checks if bit is 0
			if @(offset + i) & (1 << j) == 0 then
				return 8 * i + j	--	returns idx
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
		assert(f_bmap(frame) == 1,"cannot deallocate empty frame ")
		
		--	sets the bitmap
		toggle_bmap(frame)
		
		--	increments frames
		f_available += 1
		
		--	throws error if there is
		--	is somehow too many frames
		assert(f_available <= frms, "frame deallocation error")
end

--	toggles the bitmap value
function toggle_bmap(idx)
	--	gets the address
	local ma = moffset + flr(idx / 8)
	
	--	pokes the bit in question
	poke(ma, @ma ^^ (1 << (idx % 8)))
end

--	checks the state of a flag
function f_bmap(idx)
	--	gets the address
	local ma = offset + flr(idx / 8)
	
	--	shifts right so the important
	--	bit is the first one, and
	--	then masks all upper bits
	return (@ma >> (idx % 8)) & 1
end


-- returns a single bit at a specified memory address
function is_bit(word_i, bit_i, from_bmap)

    -- gets the start of from where to index
    local ms = mstart
    if (from_bmap == nil) from_bmap = moffset

    return 

end



--	ensures memory accesses
--	are legal accesses
function c_access(o)
	assert(o < word_size,"illegal access right ("..o..")")
	assert(o >= 0,"illegal access left")
end

--	debug prinout
function draw_memory()
	print("bytes: "..word_size)
	print("mtotal:\t"..mtotal)
	print("frames:\t"..f_available)
	print("f:\t\t"..frms)
	print("bmap:\t"..bmap.." => "..bmap * 8)
	print("mstart:\t"..bmap_end)
	print(moffset.." "..mstart.."-"..mend)
end
