local e = _G.PolarisNav

local Mesh = e.Mesh

local function get_value()
	local value
	local state = e.store:getState()
	for object in next, state.selection do
		if object.MT == Mesh.MT then
			if value == nil then
				value = object.Visible
			elseif value ~= object.Visible then
				return nil
			end
		end
	end
	return value
end

local function set_value(value)
	local state = e.store:getState()
	for object in next, state.selection do
		if object.MT == Mesh.MT and object.Visible then
			object:set_visible(value)
		end
	end
end

return {
	name = 'Visibile';
	section = 'Mesh';
	type = 'property';
	hint = true;
	data = setmetatable({}, {
		__index = function(data, key)
			return get_value()
		end;
		__newindex = function(data, key, value)
			return set_value(value)
		end;
	});
	is_relevant = function()
		local state = e.store:getState()
		for object in next, state.selection do
			if object.MT == Mesh.MT then
				return true
			end
		end
	end;
}