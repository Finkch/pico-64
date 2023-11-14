-- ints
function int()
    local int = {frame = frame()}

    setmetatable(int, int_mt)
    return int
end

function init_ints()
    int_mt = {}
end
