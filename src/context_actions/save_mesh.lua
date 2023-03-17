local e = _G.PolarisNav

local Mesh = e.Mesh

return {
	name = 'Save';
	section = 'Mesh';
	type = 'button';
	priority = 2;
	is_relevant = function()
		local state = e.store:getState()
		for object in next, state.selection do
			if object.MT == Mesh.MT then
				return true
			end
		end
	end;
	on_action = function()
		local state = e.store:getState()
		for object in next, state.selection do
			if object.MT == Mesh.MT then
				e.op.save_mesh(object)
			end
		end
	end;
}