-- floats
function float()
    local fl = {frame = frame()}


    setmetatable(fl, float_mt)
    return fl
end

function init_floats()
    float_mt = {}
end