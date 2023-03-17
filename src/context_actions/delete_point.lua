local e = _G.PolarisNav

local Point = e.Point

return {
	name = 'Delete';
	section = 'Point';
	type = 'button';
	priority = 1;
	is_relevant = function()
		local state = e.store:getState()
		for object in next, state.selection do
			if object.MT == Point.MT then
				return true
			end
		end
	end;
	on_action = function()
		local s_update = {}
		for object in next, state.selection do
			if object.MT == Point.MT then
				object:remove()
				object.mesh:rmv_point(object)
				s_update[point] = false
			end
		end
		e.go.selection_update(s_update)
	end;
}