
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


local Point = e.Point

local Mesh = {}
Mesh.MT = { __index = Mesh }
function Mesh.new()
	return setmetatable({
		id = nil;
		points = {};
		reflexes = {};
		surfaces = {};
		barriers = {};
		connections = {};
		c_conns = {};

		octree = e.Octree.Octree(0, 0, 0, 10);

		Name = 'Mesh';
		Visible = false;
	}, Mesh.MT)
end

function Mesh:reset()

	self.octree = e.Octree.Octree(0, 0, 0, 10);

end

function Mesh:add_point(point)
	local id = #self.points + 1
	self.points[id] = point
	point.id = id
	point.mesh = self
	if point.ptype >= Point.REFLEX then
		self.reflexes[point] = true
	end
end

function Mesh:add_surface(surface)
	local id = #self.surfaces + 1
	self.surfaces[id] = surface
	surface.id = id
	surface.mesh = self
end

function Mesh:add_barrier(surface)
	local id = #self.barriers + 1
	self.barriers[id] = surface
	surface.id = id
	surface.mesh = self
	surface.is_barrier = true
end

function Mesh:add_action(action)
	local id = #self.c_conns + 1
	self.c_conns[id] = action
	action.id = id
end

function Mesh:load_surfaces()
	local tree = self.octree
	for i, s in ipairs(self.surfaces) do

		tree:add(s:get_AABB(), s)

	end
end

function Mesh:rmv_point(point)
	local t = self.points
	local rep = t[#t]
	t[point.id] = rep
	if rep then
		t[#t] = nil
		rep.id = point.id
	end
	point.id = nil
end


function Mesh:remove(surface)
	local t = self.surfaces
	local rep = t[#t]
	t[surface.id] = rep
	t[#t] = nil

	local aabb = surface:get_AABB()
	self.octree:remove(aabb, surface)
	
	if rep then
		rep.id = surface.id
	end
	
	surface.id = nil

	for i, p in ipairs(surface) do
		p.surfaces[surface] = nil
		local is_unused = true
		local is_blocked = true
		for surface in next, p.surfaces do
			is_unused = false
			if not surface.is_barrier then
				is_blocked = false
				break
			end
		end
		if is_unused then
			self:rmv_point(p)
		elseif is_blocked then
			p.ptype = Point.BLOCKED
		end
	end
end




function Mesh:cache_lines()
    for i, s in ipairs(self.surfaces) do
        s:cache_lines()
    end
    for i, p in ipairs(self.points) do
        for s in next, p.surfaces do
            if not s.is_barrier and not p.lines_by_s[s] then
                error('bad cache lines. ' .. p.id .. ' has ' .. s.id .. ' in surfaces, but not lines_by_s.')
            end
        end
    end
end



return Mesh