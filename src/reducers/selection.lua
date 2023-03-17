local e = _G.PolarisNav

local DEFAULT = {}

return function(action, old, new, nxt)
	if action.type == '@@INIT' then
		new.selection = DEFAULT
		return
	end

	local name = nxt()
	if name == 'clear' then
		new.selection = DEFAULT
	elseif name == 'update' then
		local s = table.clone(old.selection)
		new.selection = s
		for object, add_or_remove in next, action.updates do
			if add_or_remove then
				s[object] = true
			else
				s[object] = nil
			end
		end
	else
		error('reducer does not implement ' .. name)
	end
end