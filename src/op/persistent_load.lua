local e = _G.PolarisNav
local p = e.plugin
local ls = e.interpret

--[[
    prefixes
    ! = interpret and return
    # = return value
]]

return function (key)
    local value : string = p:GetSetting(key)
    local valtype = typeof(value)
    if valtype == 'string' then
        local first_char = string.sub(value, 1, 1)
        if first_char == '!' then
            return ls('return ' .. (string.sub(value, 2, -1) or 'nil'))
        elseif first_char == '#' then
            return string.sub(value, 2, -1)
        end
        error("Attempted to load persistent value '" .. key .. "' which does not specify if it should be interpreted or returned as a String.")
    elseif valtype == 'nil' or valtype == 'number' or valtype == 'boolean' then
        return value
    end
end