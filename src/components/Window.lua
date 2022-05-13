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
	return e.Roact.createElement(e.Roact.Portal, {
		target = self.win
	}, self.props[e.Roact.Children])
end

function component:didMount()
	self.win.Enabled = true
end

function component:willUnmount()
	self.win:Destroy()
end

return component