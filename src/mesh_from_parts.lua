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

local Point = e.Point
local Surface = e.Surface
local Mesh = e.Mesh

local U = Point.UNKNOWN

function Surface:from_part(part)
	local x, y, z,
	xx, yx, zx,
	xy, yy, zy,
	xz, yz, zz = part.CFrame:components()
	local size = part.Size
	local xa = Vector3.new(xx, xy, xz) * size.x / 2
	local ya = Vector3.new(yx, yy, yz) * size.y / 2
	local za = Vector3.new(zx, zy, zz) * size.z / 2
	local p = Vector3.new(x, y, z)

	if part:IsA 'WedgePart' then
		local pts = {
			Point.new(p+xa+ya+za, U);
			nil; --Point.new(p+xa+ya-za, U);
			Point.new(p+xa-ya+za, U);
			Point.new(p+xa-ya-za, U);
			Point.new(p-xa+ya+za, U);
			nil; --Point.new(p-xa+ya-za, U);
			Point.new(p-xa-ya+za, U);
			Point.new(p-xa-ya-za, U);
		}
		
		return
			-- positive x
			self.new{pts[1], pts[4], pts[3]},
			
			-- negative x
			self.new{pts[8], pts[5], pts[7]},
			
			-- positive y
			self.new{pts[1], pts[5], pts[8], pts[4]},
		
			-- negative y
			self.new{pts[8], pts[7], pts[3], pts[4]},

			-- positive z
			self.new{pts[1], pts[3], pts[7], pts[5]}

			-- negative z
			-- self.new{pts[8], pts[4], pts[2], pts[6]}
	elseif part:IsA 'CornerWedgePart' then
		local pts = {
			nil; --Point.new(p+xa+ya+za, U);
			Point.new(p+xa+ya-za, U);
			Point.new(p+xa-ya+za, U);
			Point.new(p+xa-ya-za, U);
			nil; --Point.new(p-xa+ya+za, U);
			nil; --Point.new(p-xa+ya-za, U);
			Point.new(p-xa-ya+za, U);
			Point.new(p-xa-ya-za, U);
		}
		
		return
			-- positive x
			self.new{pts[2], pts[4], pts[3]},
			
			-- negative x
			self.new{pts[8], pts[2], pts[7]},
			
			-- positive y
			-- self.new{pts[1], pts[5], pts[6], pts[2]},
		
			-- negative y
			self.new{pts[8], pts[7], pts[3], pts[4]},

			-- positive z
			self.new{pts[2], pts[3], pts[7]},

			-- negative z
			self.new{pts[8], pts[4], pts[2]}
	elseif part:IsA 'Part' or part:IsA 'TrussPart' or part:IsA 'VehicleSeat' then
		local pts = {
			Point.new(p+xa+ya+za, U);
			Point.new(p+xa+ya-za, U);
			Point.new(p+xa-ya+za, U);
			Point.new(p+xa-ya-za, U);
			Point.new(p-xa+ya+za, U);
			Point.new(p-xa+ya-za, U);
			Point.new(p-xa-ya+za, U);
			Point.new(p-xa-ya-za, U);
		}
		
		return
			-- positive x
			self.new{pts[1], pts[2], pts[4], pts[3]},
			
			-- negative x
			self.new{pts[8], pts[6], pts[5], pts[7]},
			
			-- positive y
			self.new{pts[1], pts[5], pts[6], pts[2]},
		
			-- negative y
			self.new{pts[8], pts[7], pts[3], pts[4]},

			-- positive z
			self.new{pts[1], pts[3], pts[7], pts[5]},

			-- negative z
			self.new{pts[8], pts[4], pts[2], pts[6]}
	end
end

local max_walk_angle = 89
local min_normal_y = math.cos(math.rad(max_walk_angle))
function Mesh.from_parts(parts)
	local mesh = Mesh.new()
	for i, part in ipairs(parts) do
		for j, surface in ipairs{e.Surface:from_part(part)} do
			for k, point in ipairs(surface) do
				if not point.id then
					mesh:add_point(point)
				end
			end
			if surface.normal.Y >= min_normal_y then
				mesh:add_surface(surface)
			else
				mesh:add_barrier(surface)
			end
		end
	end
	return mesh
end

return true