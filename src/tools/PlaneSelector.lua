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

local KC = Enum.KeyCode

local PlaneSelector = {
	name = 'PlaneSelector';
	shortcut = {KC.LeftShift, KC.Three};
}

local Surface = e.Surface

function PlaneSelector:get(target, pos)
	local mesh, surface = self.util.find(target)
	return {surface}
end

function PlaneSelector:unhover()
	if not self.hovered then
		return
	end

	self.hovered.lines:Destroy()
	self.hovered.lines = nil
	self.hovered = nil
end

function PlaneSelector:hover(surface)
	if self.hovered == surface then
		return
	end
	self.fire 'unhover'

	self.hovered = surface
	surface:create_outline(self.root, e.CFG.HOVERED_COLOR)
end

local function deselect(surface)
	if surface.MT == Surface.MT then
		surface:set_props {
			Color = e.CFG.DEFAULT_COLOR;
			Transparency = e.CFG.DEFAULT_TRANS;
		}
	end
end
function PlaneSelector:deselect(surface)
	if self.hovered == surface then
		self.fire 'unhover'
		self.fire('hover', surface)
	end

	if surface then
		deselect(surface)
	else
		for surface in next, e.store:getState().selection do
			deselect(surface)
		end
	end

	local cons = self.root:FindFirstChild 'Connections'
	if cons then
		cons:Destroy()
	end
end

function PlaneSelector:select(surface)
	surface:set_props {
		Color = e.CFG.SELECTED_COLOR;
		Transparency = e.CFG.SELECTED_TRANS;
	}

	local cons = Instance.new 'Folder'
	cons.Name = 'Connections'
	surface:create_connections(cons, e.CFG.DEFAULT_CONN_COLOR)
	cons.Parent = self.root
end

function PlaneSelector:start_drag(part, pos)
	self.is_dragging = true
	if not self.is_dragging then
		return
	end
	self.raycast_params.FilterDescendantsInstances = {self.root}
end

function PlaneSelector:stop_drag()
	self.raycast_params.FilterDescendantsInstances = {}
end

return PlaneSelector