local e = _G.PolarisNav

return function(props)
	local mesh = e.store.getState().selection.mesh
	assert(mesh, 'No mesh is selected')

	local old_vis = mesh.Visible

	for i, v in ipairs(props) do
		mesh[v[1]] = v[2]
	end

	if mesh.Visible ~= old_vis then
		if mesh.Visible then
			e:load 'mesh_visualize'
			if not mesh.folder then
				mesh:create_surfaces(old.root, id, e.CFG.DEFAULT_COLOR)
			end
		elseif mesh.folder then
			mesh.folder:Destroy()
			mesh.folder = nil
		end
	end

	return new
end