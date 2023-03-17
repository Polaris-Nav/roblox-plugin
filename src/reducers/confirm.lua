local e = _G.PolarisNav

local init = {
	show = false;
	text = '';
	onConfirm = function() end;
	onCancel = function() end;
}
return function(action, old, new, nxt)
	if action.type == '@@INIT' then
		new.confirm = init
		return
	end

	local name = nxt()
	if name == 'show' then
		new.confirm = action.confirm
	elseif name == 'hide' then
		new.confirm = init
	else
		error('reducer does not implement ' .. name)
	end
end