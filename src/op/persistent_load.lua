local e = _G.PolarisNav
local p = e.plugin
local ls = e.vLua

--[[
    prefixes
    ! = interpret and return
    # = return value
]]

return function (key)
    local value : string = p:GetSetting(key)
    if typeof(value) == "string" then
        if string.sub(value, 1, 1) == "!" then
            local load, err = ls('return ' .. (string.gsub(value, "!", "", 1) or 'nil'))

            if err then
               error(err)
               return
            end

            return load()
        elseif string.sub(value, 1, 1) == "#" then
            return string.gsub(value, "#", "", 1)
        end
        error("Attempted to load persistent value '" .. key .. "' which does not specify if it should be interpreted or returned as a String.")
    elseif typeof(value) == "nil" then
        return nil
    end
end