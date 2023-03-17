local e = _G.PolarisNav

return function(mesh)
	e.go.meshes_add(mesh)

	if mesh.Visible then
		e:load 'mesh_visualize'
		mesh:create_surfaces()
	end

	e.info('Loaded mesh "' .. mesh.Name .. '"')
end