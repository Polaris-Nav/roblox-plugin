local e = _G.PolarisNav

return function (action, old, new, nxt)
	if action.type == '@@INIT' then
		new.objects = {}
		return
	end

	local name = nxt()
	if name == 'set' then
		new.objects = action.objects
	else
		error('reducer does not implement ' .. name)
	end
	return new
end