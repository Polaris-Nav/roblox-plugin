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

local PolarisNav = {}

function PolarisNav:new(plugin)
	self.plugin = plugin
	setmetatable(self, {
		__index = PolarisNav
	})

	plugin.Unloading:Connect(function()
		self:deactivate()
	end)

	self.bar = plugin:CreateToolbar 'Polaris-Nav'
	self.button = self.bar:CreateButton(
		'Reset',
		'Reset the Polaris-Nav window',
		'rbxassetid://8997413571')
	self.button.Click:Connect(function()
		self:reset()
	end)

	return self:activate()
end

function PolarisNav:activate()
	local root = workspace:FindFirstChild 'Polaris-Nav'
	if not root then
		root = Instance.new 'Folder'
		root.Name = 'Polaris-Nav'
		root.Parent = workspace
	end

	self.window = e.Roact.mount(e.App {
		plugin = self.plugin;
		root = root;
	}, game)

	return self
end

function PolarisNav:deactivate()
	if self.window then
		e.Roact.unmount(self.window)
		self.window = nil
	end
end

function PolarisNav:reset()
	self:deactivate()
	self:activate()
end

return function(...)
	return PolarisNav.new({}, ...)
end