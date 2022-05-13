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

local e = require(script.Parent.Parent)

local KC = Enum.KeyCode

local PlaneSelector = {
	shortcut = {KC.LeftShift, KC.Three};
}

function PlaneSelector:get(target, pos)
	local mesh, surface = self.util.find(target)
	return surface
end

function PlaneSelector:unhover()
	if not self.hovered then
		return
	end

	if self.hovered ~= self.selected then
		self.hovered:set_props {
			Color = e.CFG.DEFAULT_COLOR
		}
	end
	self.hovered = nil
end

function PlaneSelector:hover(surface)
	if self.hovered == surface or self.selected == surface then
		return
	end
	self.fire 'unhover'

	self.hovered = surface
	self.hovered:set_props {
		Color = e.CFG.HOVERED_COLOR
	}
end

function PlaneSelector:deselect()
	if not self.selected then
		return
	end

	self.selected:set_props {
		Color = e.CFG.DEFAULT_COLOR;
		Transparency = e.CFG.DEFAULT_TRANS;
	}

	local cons = self.root:FindFirstChild 'Connections'
	if cons then
		cons:Destroy()
	end

	local surface = self.selected
	self.selected = nil
	if self.hovered == surface then
		self.fire 'unhover'
		hover(surface)
	end
end

function PlaneSelector:select(surface)
	if self.selected then
		if self.selected == surface then
			return
		end
		self.fire 'deselect'
	end

	self.selected = surface
	self.selected:set_props {
		Color = e.CFG.SELECTED_COLOR;
		Transparency = e.CFG.SELECTED_TRANS;
	}

	local cons = Instance.new 'Folder'
	cons.Name = 'Connections'
	self.selected:create_connections(cons, e.CFG.DEFAULT_CONN_COLOR)
	cons.Parent = self.root
end

function PlaneSelector:start_drag(part, pos)
	self.is_dragging = self.selected and part:IsDescendantOf(self.selected.surface)
	if not self.is_dragging then
		return
	end
	self.mouse.TargetFilter = self.root
end

function PlaneSelector:stop_drag()
	self.mouse.TargetFilter = nil
end

return PlaneSelector