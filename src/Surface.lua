
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

local AABB = e.AABB


local util = e.util

local max_rejection_per_stud = 1e-6

local min_normal = 1 - math.sin(math.rad(89))

local h_delta = 1e-3

local mrps_cos = math.cos(math.atan(max_rejection_per_stud))

local down = Vector3.new(0, -1, 0)
local up = Vector3.new(0, 1, 0)

local Point = e.Point

local Surface = {
	thickness = 0.01
}
Surface.MT = { __index = Surface }
function Surface.new(pts)
	local is_valid, normal = Surface.calc_normal(pts)
	if not is_valid then
		return false
	end
	pts.mesh = nil;
	pts.normal = normal
	pts.connections = {}
	pts.c_conns = {}
	pts.adjacent = {}
	return setmetatable(pts, Surface.MT)
end

function Surface:notify_points()
	for i, p in ipairs(self) do
		p:add(self, i)
	end
end

function Surface:calc_normal()
	local n = #self
	local a = self[n]
	local b

	local ab_u
	for i = 1, n - 1 do
		local b = self[i]

		local delta = b.v3 - a.v3

		local delta_mag = delta.Magnitude

		if delta_mag >= util.prec then
			ab_u = delta / delta_mag
			break
		end
	end

	-- All points are identical within the given util.prec,
	-- Best normal to use is "up".
	if not ab_u then
		return false, Vector3.new(0, 1, 0)
	end

	local best_ac_u
	local best_abs_cos = 1
	for i = 1, n - 1 do
		local c = self[i]

		local delta = c.v3 - a.v3

		local delta_mag = delta.Magnitude

		if delta_mag >= util.prec then
			local ac_u = delta / delta_mag
			local cos_abs = math.abs(ab_u:Dot(ac_u))
			if cos_abs <= best_abs_cos then
				best_abs_cos = cos_abs
				best_ac_u = ac_u
			end
		end
	end

	-- All points are on the same line
	-- Best normal to use is up-ish, or to the side if the line is up
	if best_abs_cos > mrps_cos then
		local up = Vector3.new(0, 1, 0)
		if math.abs(ab_u:Dot(up)) > mrps_cos then
			return false, Vector3.new(1, 0, 0)
		else
			return false, ab_u:Cross(up:Cross(ab_u))
		end
	end

	return true, best_ac_u:Cross(ab_u)
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

function Surface:is_convex()
	local a, b = self[#self - 1].v3, self[#self].v3
	for i, c in ipairs(self) do
		c = c.v3
		local ab = b - a
		local ac = c - a
		local dot = ac:Cross(ab):Dot(self.normal)
		if dot < -1e-3 or dot < 1e-7 and ab:Dot(ac) < 0 then
			return false
		end
		a = b
		b = c
	end
	return true
end

function Surface:is_coplanar()
	local a = self[1]
	for i, b in ipairs(self) do
		if math.abs((b.v3 - a.v3):Dot(self.normal)) > 1e-5 then
			return false
		end
	end
	return true
end

function Surface:next_i(i)
	if self.normal.Y < 0 then
		return i > 1 and i - 1 or #self
	else
		return i < (#self) and i + 1 or 1
	end
end

function Surface:prev_i(i)
	if self.normal.Y < 0 then
		return i < (#self) and i + 1 or 1
	else
		return i > 1 and i - 1 or #self
	end
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
	local cos = up:Dot(self.normal)
	if math.abs(cos) < 1e-7 then
		return 0
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





function Surface.MT:__tostring()
	local pts_str = {''}
	for i, p in ipairs(self) do
		pts_str[i + 1] = tostring(p.v3)
	end
	return ('<Surface id=%d points={%s\n}>'):format(
		self.id or -1,
		table.concat(pts_str,'\n\t')
	)
end

return Surface