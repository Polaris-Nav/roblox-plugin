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

local CS = game:GetService 'CollectionService'

local KC = Enum.KeyCode

local PointSelector = {
	name = 'PointSelector';
	shortcut = {KC.LeftShift, KC.One};
}

function PointSelector:get(target, pos)
	local mesh, surface = self.util.find(target)

	local min_d2 = math.huge
	local min_v = nil
	for i, p in ipairs(surface) do
		local v = p.v3 - pos
		local d2 = v:Dot(v)
		if d2 < min_d2 then
			min_v = p
			min_d2 = d2
		end
	end

	for p, con in next, surface.c_conns do
		local v = p.v3 - pos
		local d2 = v:Dot(v)
		if d2 < min_d2 then
			min_v = p
			min_d2 = d2
		end
	end

	return min_v, mesh, con
end

function PointSelector:unhover()
	if not self.hovered then
		return
	end

	if self.hovered ~= self.selected then
		self.hovered:destroy()
		if self.existed_h then
			self.hovered:create(self.existed_h)
		end
	end
	self.hovered = nil
	self.existed_h = nil
end

function PointSelector:hover(point, mesh, con)
	self.fire 'unhover'
	if self.hovered == point or self.selected == point then
		return
	end

	self.hovered = point
	if not self.hovered.part then
		self.existed_h = false
		local root = mesh.folder or self.root
		local part = self.hovered:create(root, {
			Color = e.CFG.HOVERED_COLOR
		})
		CS:AddTag(part, 'Polaris-Point')
	else
		self.existed_h = point.part.Parent
		self.hovered.part.Color = e.CFG.HOVERED_COLOR
	end
end


function PointSelector:deselect()
	local point = self.selected
	if not point then
		return
	end
	
	self.selected = nil
	if not point.part then
		return
	end

	point:destroy()
	self.store:dispatch {
		type = 'selectNone';
	}

	if self.hovered == point then
		self.fire 'unhover'
		self.fire('hover', point)
	elseif self.existed_s then
		point:create(self.existed_s)
		self.existed_s = nil
	end
end

function PointSelector:select(point, mesh)
	if self.selected then
		if self.selected == point then
			return
		end
		self.fire 'deselect'
	end

	self.selected = point
	if point.part then
		self.existed_s = point.part.Parent
	else
		self.existed_s = nil
	end

	self.store:dispatch {
		type = 'selectPoint';
		mesh = mesh;
		point = point;
	}
	self.selected:set_props {
		Color = e.CFG.SELECTED_COLOR;
		Transparency = e.CFG.SELECTED_TRANS;
	}
end

function PointSelector:start_drag(target, pos)
	if not self.selected then
		return
	end
	self.is_dragging = true
	self.is_snapped = true
	self.offset = nil
	self.snap_pos = self.selected.v3
	self.mouse.TargetFilter = self.root
end

function PointSelector:drag(pos)
	if self.is_snapped then
		local v = pos - self.snap_pos
		if v:Dot(v) >= 0.2 then
			self.is_snapped = false
			if not self.offset then
				self.offset = self.selected.v3 - pos
			end
		else
			return
		end
	end
	self.selected:update(pos + self.offset)
end

function PointSelector:stop_drag()
	self.mouse.TargetFilter = nil
end

return PointSelector