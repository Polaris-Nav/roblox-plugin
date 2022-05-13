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

local ManualConnector = {
	shortcut = {KC.LeftShift, KC.C};
}

function ManualConnector:get(target, pos)
	local mesh, surface = self.util.find(target)
	return mesh, surface, pos
end

function ManualConnector:select(mesh, surface, pos)
	local point = e.Point.new(pos, e.Point.ACTION)

	e:load 'mesh_line_of_sight'
	point.sight = mesh:get_visible(pos, surface)
	for p, cost in next, point.sight do
		p.sight[point] = cost
	end
	mesh:add_point(point)

	if surface.points then
		point:create(surface.points)
	end

	local selected = self.selected
	if selected then
		local c_conn = e.Jump {
			bidirectional = false;
			at = {[selected.point] = true};
			to = {[point] = true};
		}
		selected.surface.c_conns[selected.point] = c_conn
		selected.point:add(selected.surface, c_conn)

		surface.c_conns[point] = c_conn
		point:add(surface, c_conn)
		
		mesh:add_action(c_conn)
		if selected.mesh ~= mesh then
			selected.mesh:add_action(c_conn)
		end

		if mesh.folder then
			c_conn:create(mesh.folder)
		end
		
		self.selected = nil
		self.util.set_mode(self.modes.PointSelector)
	else
		self.selected = {
			mesh = mesh;
			surface = surface;
			point = point;
		}
	end
end

return ManualConnector