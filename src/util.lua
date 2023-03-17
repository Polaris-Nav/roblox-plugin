
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


local util = {}

local prec = 1e-3
local prec2 = prec^2
util.prec = prec

local abs = math.abs

local max_parallel_angle = 1
local mpa_cos = math.cos(max_parallel_angle/360 * 2*math.pi)

-- compute epsilon real quick
local e = 1
while 1 + e ~= 1 do
	e = e * 0.5
end
util.e = e



function util.mod1_dec(x, m)
	return (x - 2) % m + 1
end

function util.mod1_inc(x, m)
	return x % m + 1
end

function util.bind(f, obj)
	return function(...)
		return f(obj, ...)
	end
end

function util.union_k(...)
	local r = {}
	for i, t in ipairs{...} do
		for k, v in next, t do
			r[k] = v
		end
	end
	return r
end

function util.union_i(...)
	local r = {}
	for j, t in ipairs{...} do
		for i, v in ipairs(t) do
			r[#r + 1] = v
		end
	end
	return r
end

function util.validate_bool(txt)
	txt = txt:lower()
	if txt == 'true' or txt == 't' then
		return true
	elseif txt == 'false' or txt == 'f' then
		return false
	end
end

function util.get_trace(msg)
	return msg .. '; ' .. debug.traceback()
end

function util.pcall(f, ...)
	return xpcall(f, util.get_trace, ...)
end



return util