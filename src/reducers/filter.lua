local e = _G.PolarisNav

return function (action, old, new, nxt)
	if action.type == '@@INIT' then
		new.filter = {
			Humanoids = true;
			Tools = true;
			Unanchored = true;
			Uncollidable = false;
		}
		return
	end

	local name = nxt()
	if name == 'set' then
		local t = {}
		for k, v in next, old.filter do
			t[k] = v
		end
		for i, v in ipairs(action.values) do
			t[v[1]] = v[2]
		end
		new.filter = t
	else
		error('reducer does not implement ' .. name)
	end
	return new
end