return function (action, old, new, nxt)
	if action.type == '@@INIT' then
		new.size = Vector2.new(300, 300)
		return
	end

	local name = nxt()
	if name == 'set' then
		new.size = action.size
	else
		error('reducer does not implement ' .. name)
	end
end