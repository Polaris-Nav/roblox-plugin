local e = _G.PolarisNav

return function(mesh)
	e.go.meshes_remove(mesh)
	if e.store:getState().selection[mesh] then
		e.go.selection_update {
			[mesh] = false;
		}
	end

	if mesh.Visible and mesh.folder then
		mesh.folder:Destroy()
		mesh.folder = nil
	end

	local name = 
	e.info('Unloaded mesh "' .. mesh.Name .. '"')
end