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

local CS = game:GetService 'CollectionService'
local studio = settings().Studio

-- include tool reducers
require(script.Parent.Parent.tool_reducers)

local component = e.Roact.Component:extend(script.Name)

local function updateTheme()
	local colors = {}
	local theme = studio.Theme

	for i, item in ipairs(Enum.StudioStyleGuideColor:GetEnumItems()) do
		colors[item.Name] = theme:GetColor(item.Value)
	end

	e.store:dispatch {
		type = 'themeChanged';
		colors = colors;
	}
end

local function getMeshes(root)
	local saves = CS:GetTagged 'Polaris-Save'
	local meshes = {}
	e:load 'mesh_from_save'
	for i, save in ipairs(saves) do
		local mesh = e.Mesh.load_dir(save)
		meshes[i] = mesh
		if mesh.Visible and (not mesh.folder) then
			e:load 'mesh_visualize'
			mesh:create_surfaces(root, i, e.CFG.DEFAULT_COLOR)
		end
	end
	return meshes
end

function component:init(props)
	local plugin = props.plugin
	e.plugin = plugin

	local meshes = getMeshes(props.root)
	
	e.store = e.Rodux.Store.new(e.rootReducer, {
		root = props.root;
		mode = 'Welcome';
		meshes = meshes;
		messages = {};
		selection = {
			mesh = #meshes > 0 and #meshes or nil;
			type = nil;
			object = nil;
		};
		params = {
			Gravity = workspace.Gravity;
			JumpPower = 50;
			WalkSpeed = 16;
			Radius = 1;
			Height = 5;
		};
		include = {};
		filter = {
			Humanoids = true;
			Tools = true;
			Unanchored = true;
			Uncollidable = false;
		};
		confirm = {};
		token = plugin:GetSetting 'token';
		saves = {};
		saves_con = {};
	})

	e.refreshSaves{}

	updateTheme()
	studio.ThemeChanged:Connect(updateTheme)

	e.tools.connect(props.plugin, e.store, props.root)
end

function component:render()
	return e.StoreProvider({
		store = e.store,
	}, {
		e.Window({}, {
			e.Pane {
				Size = UDim2.new(1, 0, 1, 0);
			};
			e.Welcome();
			e.Auth();
			e.Edit();
			e.Load();
			e.Generate();
			e.Generate_Params();
			e.Messages();
			e.Confirmation();
		})
	})
end

function component:willUnmount()
	e.tools.disconnect()
	for i, instance in ipairs(CS:GetTagged 'Polaris-Mesh') do
		instance:Destroy()
	end
	for i, instance in ipairs(CS:GetTagged 'Polaris-Point') do
		instance:Destroy()
	end
	--e.plugin:SetSetting('state', e.store:getState())
end

function e.reducers.transferToken(action, old, new)
	if state.token == nil then
		state.token = action.token
	end
	return new
end

function e.reducers.themeChanged(action, old, new)
	new.colors = action.colors
	return new
end

return component