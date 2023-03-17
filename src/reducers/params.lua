local e = _G.PolarisNav

return function (action, old, new)
	if action.type == '@@INIT' then
		new.params = {
			Gravity = workspace.Gravity;
			JumpPower = 50;
			WalkSpeed = 16;
			Radius = 1;
			Height = 5;
		}
		return
	end

	local t = e.op.shallow_copy(old.params, {})
	for i, v in ipairs(action.values) do
		t[v[1]] = v[2]
	end
	new.params = t
end