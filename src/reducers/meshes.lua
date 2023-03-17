local e = _G.PolarisNav


return function(action, old, new, nxt)
	if action.type == '@@INIT' then
		new.meshes = {}
		return
	end

	local name = nxt()
	local meshes
	if name == 'add' then
		meshes = {}
		for i, mesh in ipairs(old.meshes) do
			meshes[i] = mesh
		end
		local id = #meshes + 1
		meshes[#meshes + 1] = action.mesh
	elseif name == 'remove' then
		meshes = {}
		for i, mesh in ipairs(old.meshes) do
			if mesh ~= action.mesh then
				meshes[#meshes + 1] = mesh
			end
		end
	elseif name == 'set' then
		meshes = action.meshes
	else
		error('reducer does not implement ' .. name)
	end
	for i, mesh in ipairs(old.meshes) do
		mesh.id = nil
	end
	for i, mesh in ipairs(meshes) do
		mesh.id = i
	end
	new.meshes = meshes
end