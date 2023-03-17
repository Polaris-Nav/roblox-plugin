local e = _G.PolarisNav

local CS = game:GetService 'CollectionService'

local function add(action, old, new)
	local s = {con = {}}
	new.saves = s
	for i, save in ipairs(old.saves) do
		s[i] = save
		s.con[i] = old.saves.con[i]
	end
	local id = #s + 1
	s[id] = action.save
	s.con[id] = action.save.Destroying:Connect(
		e.bind(e.go.saves_remove, action.save))
end

local function refresh(old, new)
	if old then
		for i, con in ipairs(old.saves.con) do
			con:Disconnect()
		end
	end
	new.saves = CS:GetTagged 'Polaris-Save'
	local con = {}
	new.saves.con = con
	for i, save in ipairs(new.saves) do
		con[i] = save.Destroying:Connect(
			e.bind(e.go.saves_remove, save))
	end
end

local function remove(action, old, new)
	local saves = {con = {}}
	new.saves = saves
	for i, save in ipairs(old.saves) do
		if save ~= action.save then
			local id = #new.saves + 1
			saves[id] = save
			saves.con[id] = old.saves.con[i]
		end
	end
end

return function(action, old, new, nxt)
	if action.type == '@@INIT' then
		return refresh(old, new)
	end

	local name = nxt()
	if name == 'add' then
		add(action, old, new)
	elseif name == 'refresh' then
		refresh(old, new)
	elseif name == 'remove' then
		remove(action, old, new)
	else
		error('reducer does not implement ' .. name)
	end
end