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

local CS = game:GetService 'CollectionService'

local KC = Enum.KeyCode

local PointSelector = {
	name = 'PointSelector';
	shortcut = {KC.LeftShift, KC.One};
}

local Point = e.Point

function PointSelector:get(target, pos)
	local mesh, surface = self.util.find(target)

	if not pos then
		return {surface}
	end

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

	return {min_v}
end

function PointSelector:unhover()
	if not self.hovered then
		return
	end

	if e.store:getState().selection[self.hovered] then
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
	if self.hovered == point or e.store:getState().selection[point] then
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

local function deselect(self, point)
	if point.MT ~= Point.MT or not point.part then
		return
	end

	point:destroy()

	if self.hovered ~= point and self.existed_s then
		point:create(self.existed_s)
		self.existed_s = nil
	end
end

function PointSelector:deselect(point)
	if self.hovered == point then
		self.fire 'unhover'
		self.fire('hover', point)
	end

	if point then
		deselect(self, point)
	else
		for point in next, e.store:getState().selection do
			deselect(self, point)
		end
	end
end

function PointSelector:select(point, mesh)
	if point.part then
		self.existed_s = point.part.Parent
	else
		self.existed_s = nil
	end

	e.go.selection_update {
		[point] = true;
	}
	point:set_props {
		Color = e.CFG.SELECTED_COLOR;
		Transparency = e.CFG.SELECTED_TRANS;
	}
end

function PointSelector:start_drag(target, pos)
	self.is_dragging = true
	self.is_snapped = true
	self.offset = nil
	self.snap_pos = pos
	self.raycast_params.FilterDescendantsInstances = {self.root}
end

function PointSelector:drag(pos)
	if self.is_snapped then
		local v = pos - self.snap_pos
		if v:Dot(v) >= 0.2 then
			self.is_snapped = false
			if not self.offset then
				self.offset = self.snap_pos - pos
			end
		else
			return
		end
	end
	for p in next, e.store:getState().selection do
		if p.MT == Point.MT then
			p:update(pos + self.offset)
		end
	end
end

function PointSelector:stop_drag()
	self.raycast_params.FilterDescendantsInstances = {}
end

return PointSelector