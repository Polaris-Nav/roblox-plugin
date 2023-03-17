local e = _G.PolarisNav

return function(action, old, new, nxt)
	if action.type == '@@INIT' then
		new.mode = 'Welcome'
		return
	end

	local name = nxt()
	if name == 'set' then
		new.mode = action.mode
	end
end