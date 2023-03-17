local e = _G.PolarisNav

return function(action, old, new, nxt)
	if action.type == '@@INIT' then
		local root = workspace:FindFirstChild 'Polaris-Nav'
		if not root then
			root = Instance.new 'Folder'
			root.Name = 'Polaris-Nav'
			root.Archivable = false
			root.Parent = workspace
		end
		new.root = root
		return
	end
end