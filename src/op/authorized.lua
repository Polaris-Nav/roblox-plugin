local e = _G.PolarisNav

local CS = game:GetService 'CollectionService'

local function getMeshes(root)
	local saves = CS:GetTagged 'Polaris-Save'
	local meshes = {}
	e:load 'mesh_load'
	for i, save in ipairs(saves) do
		meshes[i] = e.Mesh.load_dir(save)
	end
	return meshes
end

return function()
	local state = e.store:getState()
	
	local meshes = getMeshes(state.root)

	e:load 'mesh_visualize'
	for i, mesh in ipairs(meshes) do
		if mesh.Visible then
			mesh:create_surfaces()
		end
	end
	e.go.meshes_set(meshes)

	if #meshes == 0 then
		e.go.mode_set 'Generate'
		e.go.selection_clear()
	else
		e.go.mode_set 'Edit'
		e.go.selection_update {
			[meshes[1]] = true
		}
	end
end