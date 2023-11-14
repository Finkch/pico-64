--	memory management

--	starts at   0x4300 (17152)
--	ends at     0x5e00 (24064)
--	length of   0x1B00 (6912)

--	numbers are signed 16-bit
--	so 2^15-1 is the largest
--	that's 32767

function init_memory(word_size)
	
	--	upper limit bit map size
	bmap = mtotal / word_size / 8 + 2 * word_size
	
	--	number of frames
	frms = flr((mtotal - bmap) / word_size)
	
	--	tracks available frames
	f_available = frms
	
    bmap_end = mtotal - frms * word_size

	--	start of float memory
	mstart = moffset + bmap_end
end


--	allocates a frame as occupied
--	returns the frame's index
function allocate(fnum)

	--	gets the index of the 
	--	first available frame
    local faf = -1
    if (fnan == nil) faf = get_faf()
	
	--	throws error if there's no
	--	memory available
	assert(faf >= 0, "can't find frame "..tostr(faf))

    -- ensures frame is empty
    --assert(faf)
		
	--	toggles the bitmap
	toggle_bmap(faf)
	
	--	decrements frames
	f_available -= 1
	
	--	checks if out of frames
	assert(f_available >= 0, "out of memory")
	
	--	clears the frame
	clear_mem(mstart + faf * word_size, word_size)
	
	--	returns the frame's index
	return faf, mstart + faf * word_size
end

--	searches through the bitmap
--	for the first instance of an
--	empty frame, i.e. a zero
function get_faf()
	for i = 0, bmap do	--	all bytes
		for j = 0, 7 do	--	bit in btye
			--	checks if bit is 0
			if @(moffset + i) & (1 << j) == 0 then
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
	local ma = moffset + flr(idx / 8)
	
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
    
    -- checks for seg fault
    can_access(word_i, bit_i, from_bmap)

    -- masks all unwanted bits, then shifts right until the bit is in the LSB
    return (@(ms + word_i * word_size) & (0x80 >> bit_i)) >> (7 - bit_i)
end

-- checks if a word is zero
function is_zero(word_i, from_bmap)
    m_access(word_i)
    for i = 0, word_size - 1 do
        if (@(mstart + word_i * word_size + i) != 0) return 1 
    end
    return 0
end



-- a safe poke (for words)
function powo(addr, vals, reverse)

    if (reverse == nil) reverse = false

    assert(#vals < word_size, "trying to poke too many values!")
    a_access(addr) -- checks for seg fault

    for i = 0, #vals - 1 do
        if reverse then
            poby(addr + i, vals[i + 1])
        else
            poby(addr + word_size - i - 1, vals[i + 1])
        end
    end
end

-- a safe poke (for bytes)
function poby(addr, value)
    assert(value < 0xff, "trying to set btye with too large value!")
    a_access(addr) -- for seg fault
    
    poke(addr, value)
end

-- a safe poke (for bits)
function pobi(addr, b_i, value)
    assert(value == 0 or value == 1, "not a bit value!")
    b_access(b_i) -- checks if the bit is within the word

    -- masks only the bit we want to set
    -- then "or" in the value at the correct position
    poke(addr, (@addr & ~(0x80 >> b_i)) | ((value == 1) and 0x80 or 0x0) >> b_i)
end



--	ensures memory accesses
--	are legal accesses

-- bit in word, relative word
function can_access(w_i, b_i, from_bmap)
    c_access(b_i)
    m_access(w_i, from_bmap)
end

-- bit in bytes
function b_access(b_i)
    assert(b_i < 8, "illegal access right")
	assert(b_i >= 0, "illegal access left")
end

-- bit in word
function c_access(b_i)
	assert(b_i < word_size, "illegal access right")
	assert(b_i >= 0, "illegal access left")
end

-- relative word
function m_access(w_i, from_bmap)

    -- gets the start of from where to check
    local ms = mstart
    if (from_bmap == nil) from_bmap = moffset

    -- checks access
    assert(ms + w_i < moffset + mtotal, "segmentation fault right")
    assert(ms + w_i >= moffset, "segmentation fault left")
end

-- absolute address
function a_access(addr)
    assert(addr < mend, "segmentation fault right")
    assert(addr >= mstart, "segmentation fault left")
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
