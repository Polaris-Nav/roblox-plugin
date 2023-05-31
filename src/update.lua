--[[
	This part of the plugin is used to fix possible errors when users update the Plugin or install it for the first time.
]]

local Plugin : Plugin
local stringify = require(script.Parent.stringify)

local currentVersion = '0.0.0' -- the current version of the plugin.

local updateFunctions = {
	[1] = {
        ["version"] = "pre-0.0.0";
        ["execute"] = function()
            -- Fresh install / before 0.0.0
            local uid = Plugin:GetSetting('user-id')
            local uid2 = Plugin:GetSetting('UserId')
            local tok = Plugin:GetSetting('refresh-token')
            local ses = Plugin:GetSetting('session')
            
            local baseTable = {}
            if uid or uid2 then
                baseTable['user-id'] = uid or uid2
                Plugin:SetSetting('user-id', nil)
                Plugin:SetSetting('UserId', nil)
            end
            if tok then
                baseTable['refresh-token'] = tok
                Plugin:SetSetting('refresh-token', nil)
            end
            if ses then
                baseTable['session'] = ses
                Plugin:SetSetting('session', nil)
            end
            if baseTable ~= {} then
                Plugin:SetSetting('auth', '!' .. stringify(baseTable))
            else
                Plugin:SetSetting('auth', '!{}')
            end
        end
    }
}

local function update(pl)
	Plugin = pl
	local lastPluginVersion = Plugin:GetSetting('pluginVersion')
	if lastPluginVersion ~= '#' .. currentVersion then
		if lastPluginVersion == nil then
			updateFunctions[1].execute()
		else
            for i = 1, #updateFunctions do
                local version = updateFunctions[i].version
                if version > lastPluginVersion and version <= currentVersion and version ~= "pre-0.0.0" then
                    updateFunctions[i].execute()
                end
            end
		end
		Plugin:SetSetting('pluginVersion', '#' .. currentVersion)
		print('Successfully updated plugin values to version ' .. currentVersion .. '!')
	end
end

return update