local e = _G.PolarisNav
local p = e.plugin
local stringify = e.stringify

return function (key, value)
    local valtype = typeof(value)
    if valtype == 'string' then
        p:SetSetting(key, '#' .. value)
    elseif valtype == 'nil' or valtype == 'number' or valtype == 'boolean' then
        p:SetSetting(key, value)
    else
        p:SetSetting(key, '!' .. stringify(value))
    end
end