local e = _G.PolarisNav
local p = e.plugin
local stringify = e.stringify

return function (key, value)
    if typeof(value) == "string" then
        p:SetSetting(key, "#" .. value)
    elseif typeof(value) == nil then
        p:SetSetting(key, value)
    else
        p:SetSetting(key, "!" .. stringify(value))
    end
end