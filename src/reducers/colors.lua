local e = _G.PolarisNav

local studio = settings().Studio
local function get_colors()
	local colors = {}
	local theme = studio.Theme

	for i, item in ipairs(Enum.StudioStyleGuideColor:GetEnumItems()) do
		colors[item.Name] = theme:GetColor(item.Value)
	end

	return colors
end

return function (action, old, new, nxt)
	if action.type == '@@INIT' then
		new.colors = get_colors()
		return
	end

	local name = nxt()
	if name == 'refresh' then
		new.colors = get_colors()
	else
		error('reducer does not implement ' .. name)
	end
end