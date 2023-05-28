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

local component = e.Roact.Component:extend(script.Name)

function component:init(props)
	self.win = e.plugin:CreateDockWidgetPluginGui(
		'Polaris-Nav',
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Right,
			false,
			false
		)
	)
	self.win.Title = 'Polaris-Nav'
end

function component:render()
	self.win.Enabled = self.props.is_active
	return e.Roact.createElement(e.Roact.Portal, {
		target = self.win
	}, self.props[e.Roact.Children])
end

local function size_update(window)
	local cur_size = window.AbsoluteSize
	local old_size = e.store:getState().size
	if cur_size.X ~= old_size.X or cur_size.Y ~= old_size.Y then
		e.go.size_set(cur_size)
	end
end
function component:didMount()
	self.update_con = RS.PostSimulation:Connect(e.bind(size_update, self.win))
end
function component:willUnmount()
	self.win:Destroy()
	self.update_con:Disconnect()
end

return e.connect(function(state)
	return {
		is_active = state.is_active
	}
end)(component)