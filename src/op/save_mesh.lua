local e = _G.PolarisNav

local CS = game:GetService 'CollectionService'

return function(mesh)
	local root = Instance.new 'Folder'
	root.Name = mesh.Name
	e:load 'mesh_save'
	mesh:save_dir(root)

	local parent = game:GetService 'ServerStorage'
	local existing = parent:FindFirstChild(mesh.Name)
	if existing and CS:HasTag(existing, 'Polaris-Save') then
		e.go.confirm_show(
			'A mesh named "' .. mesh.Name .. '" already exists in ServerStorage. Do you want to continue and overwrite it? If not, the mesh will not be saved.',
			function()
				e.go.saves_add(root)
				root.Parent = parent
				existing:Destroy()
			end
		)
	else
		e.go.saves_add(root)
		root.Parent = parent
	end
end