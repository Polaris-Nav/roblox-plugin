
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


local util = e.util
local Point = e.Point
local Surface = e.Surface
local Mesh = e.Mesh

local UP = Vector3.new(0, 1, 0)
local eps = 1e-7

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



function Point:line_of_sight(start_v3, goal_v3, v)
	-- find path between the points
	local s_neg, s_pos
	local c_neg, c_pos
	local search_lines = true
	local d = goal_v3 - self.v3
	for p, s in next, self.lines_by_p do
		local u = (p.v3 - self.v3).Unit
		local r = d - u.Unit:Dot(d)
		if r.X * r.Z + r.Z * r.Z < 0.0001 then
			return true
		end

		local sine = v:Cross(u).Y
		local cos = v:Dot(u)
		if sine < -eps then
			if not c_neg or cos > c_neg then
				c_neg = cos
				s_neg = s
			end
		elseif sine > eps then
			if not c_pos or cos > c_pos then
				c_pos = cos
				s_pos = s
			end
		elseif cos > 0 then
			search_lines = false
			if p:line_of_sight(start_v3, goal_v3, v) then
				return true
			end
		end
	end

	if not (search_lines and s_neg and s_pos) then
		return false
	end

	local s = s_neg[1]
	if s ~= s_pos[1] and s ~= s_pos[2] then
		s = s_neg[2]
	end
	if s then
		return s:_line_of_sight(start_v3, goal_v3, v,
			s:next_i(self.surfaces[s]))
	end

	return false
end

function Surface:_line_of_sight(start_v3, goal_v3, v, sid)
	local prev_v3 = self[sid].v3
	local i = self:next_i(sid)
	while i ~= sid do
		local p_v3 = self[i].v3
		if v:Cross(p_v3 - start_v3).Y < 0 then
			if (goal_v3 - prev_v3):Cross(p_v3 - prev_v3).Y >= 0 then
				return true
			end

			local s = self.adjacent[i]
			if s then
				return s:line_of_sight(start_v3, goal_v3, v, self[i].surfaces[s])
			else
				return false
			end
		end
		i = self:next_i(i)
		prev_v3 = p_v3
	end

	return false
end

function Surface:line_of_sight(start_v3, goal_v3)
	local v = goal_v3 - start_v3
	if v.Magnitude < util.prec then
		return true
	end
	for i, p in ipairs(self) do
		if v:Cross(p.v3 - start_v3).Y > 0 then
			return self:_line_of_sight(start_v3, goal_v3, v, i)
		end
	end

	return false
end



function Surface:cache_lines()
	local adj = self.adjacent
	local prev = self[#self]
	for i, p in ipairs(self) do
		p:cache_line(prev, self)
		prev:cache_line(p, self)

		for s, sid in next, p.surfaces do
			if s[s:next_i(sid)] == prev then
				adj[i] = s
				break
			end
		end

		prev = p
	end
end

function Mesh:get_visible(pos, surface)
	local adj = {}
	for reflex in next, self.reflexes do
		if surface:line_of_sight(pos, reflex.v3) then

			adj[reflex] = (pos - reflex.v3).Magnitude

		end
	end
	return adj
end

function Mesh:cache_lines()
	for i, s in ipairs(self.surfaces) do
		s:cache_lines()
	end
end

return true