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

-- the default function is SipHash-2-4
local cROUNDS = 2 -- number of compression rounds
local dROUNDS = 4 -- number of diffusion rounds

local function sipround(v0, v1, v2, v3)
	v0 = v0 + v1
	v1 = bit32.lrotate(v1, 5)
	v1 = bit32.bxor(v1, v0)
	v0 = bit32.lrotate(v0, 16)

	v2 = v2 + v3
	v3 = bit32.lrotate(v3, 8)
	v3 = bit32.bxor(v3, v2)
	v0 = v0 + v3

	v3 = bit32.lrotate(v3, 7)
	v3 = bit32.bxor(v3, v0)
	v2 = v2 + v1

	v1 = bit32.lrotate(v1, 13)
	v1 = bit32.bxor(v1, v2)
	v2 = bit32.lrotate(v2, 16)

	return v0, v1, v2, v3
end

-- Note, the output of this hash is expected in little endian
-- but the output is in 
local p2_8 = 256
local p2_16 = p2_8 * p2_8
local p2_24 = p2_8 * p2_16
local function siphash(ins, k0, k1, flag8)
	-- k0, k1: 8-byte key as 2 integers
	-- return result as one or two integers (if flag8)
	local inlen = #ins

	local v0 = k0
	local v1 = k1
	local v2 = bit32.bxor(0x6c796765, k0)
	local v3 = bit32.bxor(0x74656462, k1)

	local left = bit32.band(inlen, 3)
	local b = bit32.lshift(inlen, 24)

	if flag8 then
		v1 = bit32.bxor(v1, 0xee)
	end

	local ni = 1
	local ni_end = inlen - left
	while ni < ni_end do
		local m = ins[ni]
			+ p2_8  * ins[ni + 1]
			+ p2_16 * ins[ni + 2]
			+ p2_24 * ins[ni + 3]
		
		v3 = bit32.bxor(v3, m)
		for i = 1, cROUNDS do
			v0, v1, v2, v3 = sipround(v0, v1, v2, v3)
		end
		v0 = bit32.bxor(v0, m)
		
		ni = ni + 4
	end
	
	if left > 1 then
		if left > 2 then
			b = b + ins[ni + 2] * p2_16
		end
		b = b + ins[ni + 1] * p2_8
		b = b + ins[ni]
	elseif left > 0 then
		b = b + ins[ni]
	end

	v3 = bit32.bxor(v3, b)
	for i = 1, cROUNDS do
		v0, v1, v2, v3 = sipround(v0, v1, v2, v3)
	end
	v0 = bit32.bxor(v0, b)
	
	v2 = bit32.bxor(v2, flag8 and 0xee or 0xff)
	for i = 1, dROUNDS do
		v0, v1, v2, v3 = sipround(v0, v1, v2, v3)
	end

	local r1 = bit32.bxor(v1, v3)
	if not flag8 then
		return r1, nil
	end

	v1 = bit32.bxor(v1, 0xdd)
	for i = 1, dROUNDS do
		v0, v1, v2, v3 = sipround(v0, v1, v2, v3)
	end

	return r1, bit32.bxor(v1, v3)
end

return siphash