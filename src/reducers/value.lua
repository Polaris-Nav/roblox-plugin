local e = _G.PolarisNav

return function(action, old, new, nxt)
	if action.type == '@@INIT' then
		return
	end

	local name = nxt()
	if name == 'set' then
		local cur = new
		local p = action.path
		for i = 1, #p - 1 do
			cur = cur[p[i]]
		end
		cur[p[#p]] = action.value
	end
end