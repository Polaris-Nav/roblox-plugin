-- Polaris-Nav, advanced pathfinding as a library and service
-- Copyright (C) 2021 Tyler R. Herman-Hoyer
-- tyler@hoyerz.com
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/>.

local e = require(script.Parent)

local component = e.Roact.PureComponent:extend(script.Name)
local CS = game:GetService 'CollectionService'

local function selectedMesh(state, props, fields)
	local id = state.selection.mesh
	local mesh = id and state.meshes[id] or {};
	local result = {}
	for i, k in ipairs(fields) do
		result[k] = mesh[k]
	end
	return result
end

function component:render()
	local mesh_rows = {}
	local id = self.props.id
	for i, name in ipairs(self.props.names) do
		local is_cur = id == i
		mesh_rows[i] = e.RowTButton {
			is_selected = id == i;
			Text = name;
			onActivated = function()
				e.selectMesh {
					id = i;
				}
			end;
		}
	end
	mesh_rows[#mesh_rows + 1] = e.UIGridLayout {
		CellPadding = UDim2.new(0, 10, 0, 10);
		CellSize = UDim2.new(0, 120, 0, 25);
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		VerticalAlignment = Enum.VerticalAlignment.Top;
	}
	mesh_rows[#mesh_rows + 1] = e.UIPadding {
		PaddingTop = UDim.new(0, 10);
		PaddingLeft = UDim.new(0, 10);
		PaddingRight = UDim.new(0, 10);
		PaddingBottom = UDim.new(0, 10);
	}

	local rows
	local actions
	if id and not self.props.type then
		rows = {
			{'Name', 'Mesh'};
			{'Visible', true};
		}
		actions = {
			e.TButton {
				Text = 'Remove';
				TextSize = 10;
				Size = UDim2.new(0.35, 0, 0, 30);
				Position = UDim2.new(0.1, 0, 0, 10);
				[e.Roact.Event.Activated] = function(obj, input, clicks)
					if id then
						e.rmvMesh {
							mesh = self.props.mesh
						}
					end
				end;
			};

			e.TButton {
				Text = 'Save';
				TextSize = 10;
				Size = UDim2.new(0.35, 0, 0, 30);
				Position = UDim2.new(0.55, 0, 0, 10);
				[e.Roact.Event.Activated] = function(obj, input, clicks)
					if not id then
						return
					end
					local mesh = self.props.mesh

					local root = Instance.new 'Folder'
					root.Name = mesh.Name
					e:load 'mesh_save'
					mesh:save_dir(root)

					local parent = game:GetService 'ServerStorage'
					local existing = parent:FindFirstChild(mesh.Name)
					if existing and CS:HasTag(existing, 'Polaris-Save') then
						e.requireConfirm {
							text = 'A mesh named "' .. mesh.Name .. '" already exists in ServerStorage. Do you want to continue and overwrite it? If not, the mesh will not be saved.';
							onConfirm = {
								type = 'save';
								parent = parent;
								root = root;
								existing = existing;
							};
						}
					else
						e.save {
							parent = parent;
							root = root;
						}
					end
				end;
			};
		}
	elseif self.props.type == 'point' then
		rows = {
		}
		actions = {
			e.TButton {
				Text = 'Delete';
				TextSize = 10;
				Size = UDim2.new(0.35, 0, 0, 30);
				Position = UDim2.new(0.1, 0, 0, 10);
				[e.Roact.Event.Activated] = function(obj, input, clicks)
					e.deletePoint{}
				end;
			};
		}
	else
		rows = {}
	end

	return e.Context({
		Name = script.Name;
	}, {
		e.Line {
			e.HeaderBackground({}, {
				e.HeaderLabel {
					Text = 'Account';
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70 -20 -70, 0, 1);
					TextSize = 10;
					Text = 'Unlink';
					[e.Roact.Event.Activated] = e.unlink;
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70, 0, 1);
					TextSize = 10;
					Text = 'Logout';
					[e.Roact.Event.Activated] = e.logout;
				};
			});
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
			};
		};

		e.Line {
			e.HeaderBackground({}, {
				e.HeaderLabel {
					Text = 'Meshes';
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70 -20 -70, 0, 1);
					TextSize = 10;
					Text = 'New';
					[e.Roact.Event.Activated] = e.newMesh;
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70, 0, 1);
					TextSize = 10;
					Text = 'Load';
					[e.Roact.Event.Activated] = e.loadMesh;
				};
			});
			e.Line(mesh_rows);
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
			};
		};

		e.Section({
			Name = 'Actions';
		}, {
			e.Pane({
				Size = UDim2.new(1, 0, 0, 50);
			}, actions)
		});

		e.Rows {
			Name = 'Properties';
			select = selectedMesh;
			onChanged = e.setProps;
			rows = rows;
		};

		e.UIPadding {
			PaddingTop = UDim.new(0, 20);
			PaddingBottom = UDim.new(0, 20);
		};

		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
		};
	})
end

function e.reducers:addMesh(old, new)
	local meshes = {}
	for i, mesh in ipairs(old.meshes) do
		meshes[i] = mesh
	end
	local id = #meshes + 1
	meshes[#meshes + 1] = self.mesh

	if #meshes == 1 then
		new.selection = {
			mesh = 1;
		}
	end

	
	if self.mesh.Visible and (not self.mesh.folder) then
		e:load 'mesh_visualize'
		self.mesh:create_surfaces(old.root, id, e.CFG.DEFAULT_COLOR)
	end
	new.meshes = meshes

	e.reducers.addMessage(e._info(
		'Added mesh "' .. self.mesh.Name .. '" to the editor'
	), old, new)

	return new
end

function e.reducers:save(old, new)
	if self.existing then
		self.existing:Destroy()
	end
	self.root.Parent = self.parent
	e.reducers.addSave({
		save = self.root
	}, old, new)
	e.reducers.addMessage(e._info(
		'Saved mesh "' .. self.root.Name .. '" to the world'
	), old, new)
	return new
end

function e.reducers:newMesh(old, new)
	new.mode = 'Generate'
	return new
end

function e.reducers:loadMesh(old, new)
	new.mode = 'Load'
	return new
end

function e.reducers:rmvMesh(old, new)
	local meshes = {}
	for i, mesh in ipairs(old.meshes) do
		if mesh ~= self.mesh then
			meshes[#meshes + 1] = mesh
		end
	end
	new.meshes = meshes

	if #meshes == 0 then
		new.selection = {
			mesh = nil
		}
	elseif old.selection.mesh > #meshes then
		new.selection = {
			mesh = #meshes
		}
	end

	if self.mesh.Visible and self.mesh.folder then
		self.mesh.folder:Destroy()
		self.mesh.folder = nil
	end

	local name = self.mesh.Name
	e.reducers.addMessage(e._info(
		'Removed mesh "' .. name .. '" from the editor'
	), old, new)

	return new
end

function e.reducers:selectMesh(old, new)
	new.selection = {
		mesh = self.id;
		type = old.selection.type;
		object = old.selection.object;
	}
	return new
end

function e.reducers:setProps(old, new)
	local id = old.selection.mesh
	if not id then
		return
	end

	local mesh = old.meshes[id]
	local old_vis = mesh.Visible

	for i, v in ipairs(self.values) do
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

function e.reducers:logout(old, new)
	new.auth.session = nil
	e.plugin:SetSetting('session', nil)
	new.mode = 'Welcome'
	return new
end

function e.reducers:unlink(old, new)
	new.auth.UserId = nil
	new.auth.token = nil
	new.auth.session = nil
	e.plugin:SetSetting('user-id', nil)
	e.plugin:SetSetting('refresh-token', nil)
	e.plugin:SetSetting('session', nil)
	new.mode = 'Welcome'
	return new
end

return e.connect(function(state, props)
	local names = {}
	for i, mesh in ipairs(state.meshes) do
		names[i] = mesh.Name
	end
	local id = state.selection.mesh
	return {
		id = id;
		mesh = id and state.meshes[id];
		names = names;
		type = state.selection.type;
		object = state.selection.object;
	}
end)(component)