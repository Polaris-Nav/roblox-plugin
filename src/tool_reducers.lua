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

function e.reducers:selectPoint(old, new)
	new.selection = {
		mesh = self.mesh;
		type = 'point';
		object = self.point;
	}
	return new
end

function e.reducers:deletePoint(old, new)
	local s = old.selection
	s.object:remove()
	s.mesh:rmv_point(s.object)
	return e.reducers.selectNone(nil, old, new)
end

function e.reducers:selectNone(old, new)
	new.selection = {
		mesh = old.selection.mesh;
		type = nil;
		object = nil;
	}
	return new
end

return true