
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


local util = e.util

local Connection = {}
Connection.MT = {
	__index = Connection
}

function Connection.new(info)
	return setmetatable(info, Connection.MT)
end

function Connection:get_pts()
	if not self.pts then
		local sf = self.fromMesh.surfaces[self.fromID]
		local st = self.toMesh.surfaces[self.toID]
		self.pts = {
			sf:get_p(self.i1, self.t1);
			st:get_p(self.j1, self.u1);
			sf:get_p(self.i2, self.t2);
			st:get_p(self.j2, self.u2);
		}
	end
	return self.pts
end

return Connection