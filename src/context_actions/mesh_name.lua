local e = _G.PolarisNav

local Mesh = e.Mesh

local function get_value()
	local value
	local state = e.store:getState()
	for object in next, state.selection do
		if object.MT == Mesh.MT then
			if value == nil then
				value = object.Name
			elseif value ~= object.Name then
				return nil
			end
		end
	end
	return value
end

local function set_value(value)
	local state = e.store:getState()
	for object in next, state.selection do
		if object.MT == Mesh.MT then
			object.Name = value
		end
	end
end

return {
	name = 'Name';
	section = 'Mesh';
	type = 'property';
	hint = 'Mesh';
	data = setmetatable({}, {
		__index = function(data, key)
			if key == 'Name' then
				return get_value()
			end
		end;
		__newindex = function(data, key, value)
			if key == 'Name' then
				return set_value(value)
			end
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