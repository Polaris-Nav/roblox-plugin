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

local AABB = {}
local AABB_object = {
	__index = AABB
}
local AABB_class = {}

function AABB_class:__call(min, max)
	return setmetatable({
		min = min;
		max = max;
	}, AABB_object)
end

function AABB:support(dir)
	return Vector3.new(
		dir.X < 0 and self.min.X or self.max.X,
		dir.Y < 0 and self.min.Y or self.max.Y,
		dir.Z < 0 and self.min.Z or self.max.Z
	)
end
function AABB:intersection(that)
	if that.X then
		return
			that.X > this.min.X and
			that.X < this.max.X and
			that.Y > this.min.Y and
			that.Y < this.max.Y and
			that.Z > that.min.Z and
			that.Z < that.max.Z
	else
		return
			self.min.X < that.max.X and
			self.max.X > that.min.X and
			self.min.Y < that.max.Y and
			self.max.Y > that.min.Y and
			self.min.Z < that.max.Z and
			self.max.Z > that.min.Z
	end
end

return setmetatable(AABB, AABB_class)