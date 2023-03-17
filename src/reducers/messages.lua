local e = _G.PolarisNav

return function(action, old, new, nxt)
	local messages = {}
	new.messages = messages

	if action.type == '@@INIT' then
		return
	end

	local name = nxt()
	if name == 'add' then
		for i, v in ipairs(old.messages) do
			messages[i] = v
		end
		messages[#messages + 1] = action.message

		-- Automatic message removal
		task.delay(action.delay,
			e.bind(e.go.messages_remove, action.message))
	elseif name == 'remove' then
		for i, v in ipairs(old.messages) do
			if v ~= action.message then
				messages[#messages + 1] = v
			end
		end
	end
end