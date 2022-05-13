
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
local AABB = e.AABB


local down = Vector3.new(0, -1, 0)

local Surface = {
	thickness = 0.01
}
Surface.MT = { __index = Surface }
function Surface.new(pts)
	local a, b, c = pts[1].v3, pts[2].v3, pts[3].v3
	pts.normal = (c - a):Cross(b - a).Unit
	pts.connections = {}
	pts.c_conns = {}
	pts.adjacent = {}
	for i, p in ipairs(pts) do
		p.surfaces[pts] = i
	end
	return setmetatable(pts, Surface.MT)
end

function Surface:rmv(id)
	-- Surface is no longer valid
	if #self <= 3 then
		return true
	end

	local n = #self
	local i = id
	local j = i + 1
	while j <= n do
		local p = self[j]
		self[i] = p
		p.surfaces[self] = i
		i = j
		j = j + 1
	end
	self[n] = nil
end

function Surface:check_spin()
	local a, b = self[#self - 1].v3, self[#self].v3
	for i, c in ipairs(self) do
		c = c.v3
		local ab = b - a
		local ac = c - a
		local dot = ac:Cross(ab):Dot(self.normal)
		if dot < -1e-3 or dot < 0 and ab:Dot(ac) < 0 then
			return false
		end
		a = b
		b = c
	end
	return true
end

function Surface:next_i(i)
	return i < (#self) and i + 1 or 1
end

function Surface:prev_i(i)
	return i > 1 and i - 1 or #self
end

-- true if inside surface
-- nil if on boundary
-- false if outside
function Surface:is_in_bounds(v3)
	local a = self[#self].v3
	local normal = self.normal
	for i, b in ipairs(self) do
		b = b.v3
		--local normal_p = create_line(a, 5 * normal, workspace)
		--normal_p.Color = Color3.new(1, 0, 0)
		local ab = b - a
		local ap = v3 - a
		--local ab_p = create_line(a, ab, workspace)
		--ab_p.Color = Color3.new(0, 1, 0)
		--local ap_p = create_line(a, ap, workspace)
		--ap_p.Color = Color3.new(0, 0, 1)
		local cross = ab:Cross(ap)
		--local cross_p = create_line(a, cross, workspace)
		--cross_p.Color = Color3.new(1, 1, 0)
		--print(dot)
		--wait(5)
		--ab_p:Destroy()
		--ap_p:Destroy()
		--cross_p:Destroy()
		--normal_p:Destroy()
		if cross.Y > 0 then
			return false
		elseif cross.Y == 0 then
			local ap_m = ap.Magnitude
			local t = ab.Unit:Dot(ap) / ab.Magnitude
			if ap_m == 0 or t >= 0 and t <= 1 then
				return nil
			else
				return false
			end
		end
		a = b
	end
	return true
end

function Surface:get_height(v3)
	local cos = down:Dot(self.normal)
	if cos == 0 then
		return -math.huge
	end
	local v = v3 - self[1].v3
	return v:Dot(self.normal) / cos
end

function Surface:get_points(i)
	return self[self:prev_i(i)].v3, self[i].v3
end

function Surface:get_p(i, t)
	local a, b = self:get_points(i)
	return a + (b - a) * t
end

function Surface:cache_lines()
	local adj = self.adjacent
	local prev = self[#self]
	-- print('Cache Lines, #self = ' .. #self)
	for i, p in ipairs(self) do
		-- print(p.id .. ' is in surface ' .. self.id)
		-- print(p.id .. ' is connected to ' .. prev.id)
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

function Surface:get_min_max()
	local p = self[1].v3
	local minx, maxx = p.X, p.X
	local miny, maxy = p.Y, p.Y
	local minz, maxz = p.Z, p.Z
	for i = 2, #self do
		p = self[i].v3
		if p.X < minx then
			minx = p.X
		elseif p.X > maxx then
			maxx = p.X
		end
		if p.Y < miny then
			miny = p.Y
		elseif p.Y > maxy then
			maxy = p.Y
		end
		if p.Z < minz then
			minz = p.Z
		elseif p.Z > maxz then
			maxz = p.Z
		end
	end
	return Vector3.new(minx, miny, minz),
		Vector3.new(maxx, maxy, maxz)
end

function Surface:get_AABB()
	return AABB(self:get_min_max())
end





return Surface