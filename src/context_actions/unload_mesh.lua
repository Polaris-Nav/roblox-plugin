local e = _G.PolarisNav

local Mesh = e.Mesh

return {
	name = 'Unload';
	section = 'Mesh';
	type = 'button';
	priority = 1;
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
		local s_update = {}
		for object in next, state.selection do
			if object.MT == Mesh.MT then
				e.go.meshes_remove(object)
				s_update[object] = false
				if object.folder then
					object.folder:Destroy()
					object.folder = nil
				end
			end
		end
		e.go.selection_update(s_update)
	end;
}