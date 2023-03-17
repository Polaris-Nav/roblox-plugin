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

local e = _G.PolarisNav

local RS = game:GetService 'RunService'
local CS = game:GetService 'CollectionService'
local studio = settings().Studio

local component = e.Roact.Component:extend(script.Name)

function component:init(props)
	local plugin = e.plugin

	e.store = e.Rodux.Store.new(e.reducers)

	self.bar = plugin:CreateToolbar 'Polaris-Nav'

	local is_enabled = RS:IsEdit();
	local is_active = is_enabled and plugin:GetSetting 'is_active' or false;
	self.state = {
		is_enabled = is_enabled;
		is_active = is_active;
	}

	self.button = self.bar:CreateButton(
		'Editor',
		'Toggle the Polaris-Nav Editor',
		'rbxassetid://8997413571')
	self.button:SetActive(is_active)
	self.button.Enabled = is_enabled
	self.button.Click:Connect(function()
		self:setState(function(state, props)
			return {
				is_active = not state.is_active
			}
		end)
	end)

	studio.ThemeChanged:Connect(e.go.colors_refresh)
	e.tools.connect(plugin, e.store, e.store:getState().root)
end

function component:render()
	e.plugin:SetSetting('is_active', self.state.is_active)
	return e.StoreProvider({
		store = e.store,
	}, {
		e.Window({
			is_active = self.state.is_active
		}, {
			e.Pane {
				Size = UDim2.new(1, 0, 1, 0);
			};
			e.Welcome();
			e.BeginLink();
			e.CheckLink();
			e.Refresh();
			e.Login();
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
end

return component