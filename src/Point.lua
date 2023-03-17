
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



local Point = {
	
		["UNKNOWN"] = 0;
	
		["INTERIOR"] = 1;
	
		["MIDEXTERIOR"] = 2;
	
		["EXTERIOR"] = 3;
	
		["REFLEX"] = 4;
	
		["INTER"] = 5;
	
		["ACTION"] = 6;
	
		["GOAL"] = 7;
	
		["BLOCKED"] = 8;
	
}
local ptype_name = {
	
		[0] = "UNKNOWN";
	
		[1] = "INTERIOR";
	
		[2] = "MIDEXTERIOR";
	
		[3] = "EXTERIOR";
	
		[4] = "REFLEX";
	
		[5] = "INTER";
	
		[6] = "ACTION";
	
		[7] = "GOAL";
	
		[8] = "BLOCKED";
	
}
Point.is_reflex = {
	[Point.REFLEX] = true;
	[Point.INTER] = true;
	[Point.ACTION] = true;
	[Point.GOAL] = true;
}

Point.MT = {__index = Point}

local util = e.util
function Point.new(v3, ptype)
	return setmetatable({
		v3 = v3;
		id = nil;
		mesh = nil;
		surfaces = {};
		lines_by_p = {};
		lines_by_s = {};
		sight = {};
		ptype = ptype;
	}, Point.MT)
end
function Point:add(surface, i)
	self.surfaces[surface] = i
end
function Point:rmv(surface)
	self.surfaces[surface] = nil
end

function Point:remove()
	if self.part then
		self:destroy()
	end

	if self.ptype == Point.ACTION then
		for s, c_conn in next, self.surfaces do
			c_conn:destroy()
			s.c_conns[self] = nil
		end
	else
		for s, i in next, self.surfaces do
			s:rmv(i)
			s:update()
		end
	end
end

function Point:get_meshes()

end

local function insert(t, k, v)
	local cur = t[k]
	if cur then
		cur[#cur + 1] = v
	else
		t[k] = {v}
	end
end
function Point:cache_line(other, surface)
	insert(self.lines_by_p, other, surface)
	insert(self.lines_by_s, surface, other)
end

function Point.MT:__tostring()
	return ('<Point id=%d ptype=%s v3=%s>'):format(
		self.id,
		ptype_name[self.ptype],
		tostring(self.v3)
	)
end

return Point