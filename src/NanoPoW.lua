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

local siphash = require(script.Parent.Siphash)

local UINT_MAX = 2^32 - 1
local  INT_MAX = 2^31 - 1
local UINT_MOD = 2^32

-- Convert int to 4 byte table
local function to_bin(x)
	local bin = {0, 0, 0, 0}
	local byte
	for i = 1, 4 do
		byte = x % 0x100
		bin[i] = byte
		x = (x - byte) / 0x100
	end
	return bin
end

-- Create efficient key generator for the difficulty
local function keygen(difficulty)
	if difficulty > 52 then
		-- doubles begin losing precision for integers larger than 2^52,
		-- so the only way to store it in lua as a "value" is as a string.
		local mask = bit32.lshift(1, difficulty - 32) - 1
		return function(lo, hi)
			return ('%08X%08X'):format(bit32.band(hi, mask), lo)
		end
	elseif difficulty > 32 then
		-- sum still fits within a double, use that as the key
		local mask = bit32.lshift(1, difficulty - 32) - 1
		return function(lo, hi)
			return bit32.band(hi, mask) * UINT_MAX + lo
		end
	else
		-- Just a single int, mask the lower int and drop the upper
		local mask = bit32.lshift(1, difficulty) - 1
		return function(lo, hi)
			return bit32.band(lo, mask)
		end
	end
end

-- Negate 64 bit
local function inv(lo, hi)
	hi = bit32.bnot(hi)
	lo = bit32.bnot(lo)
	if lo > UINT_MAX then
		lo = 0
		hi = hi + 1
	else
		lo = lo + 1
	end
	return lo, hi
end

-- Search equaly in both hashes until we discover a canceling
-- pair in the mod difficulty
local function nano_pow(challenge)
	local key = keygen(challenge.difficulty)
	
	local x_lookup = {}
	local y_lookup = {}

	local i = 0
	local last_wait = tick()
	while true do
		local x, y
		local o_lo, o_hi

		i = i + 1
		if i == 10000 then
			local runtime = tick() - last_wait
			if runtime > 1/15 then
				wait()
				last_wait = tick()
			end
			i = 0
		end

		x = math.random(0, INT_MAX)
		o_lo, o_hi = siphash(to_bin(x), challenge.K00, challenge.K01, true)
		y = y_lookup[key(inv(o_lo, o_hi))]
		if y then
			return {x=x, y=y}
		end
		x_lookup[key(o_lo, o_hi)] = x

		y = math.random(0, INT_MAX)
		o_lo, o_hi = siphash(to_bin(y), challenge.K10, challenge.K11, true)
		x = x_lookup[key(inv(o_lo, o_hi))]
		if x then
			return {x=x, y=y}
		end
		y_lookup[key(o_lo, o_hi)] = y
	end
end

local function verify(challenge, x, y)
	--print(('x: %08x %d'):format(x, x))
	--print(('y: %08x %d'):format(y, y))
	local x_lo, x_hi = siphash(to_bin(x), challenge.K00, challenge.K01, true)
	local y_lo, y_hi = siphash(to_bin(y), challenge.K10, challenge.K11, true)
	
	local d = x_lo + y_lo
	local l = d % UINT_MOD
	local h = x_hi + y_hi + (d - l) / UINT_MOD

	--print(("H0: %08x %08x"):format(x_hi, x_lo))
	--print(("H1: %08x %08x"):format(y_hi, y_lo))
	--print(("Result: %08x %08x"):format(h, l))

	if challenge.difficulty <= 32 then
		l = l % 2^challenge.difficulty
		h = 0
	else
		h = h % 2^(challenge.difficulty - 32) 
	end

	return h == 0 and l == 0
end

return {
	calculate = nano_pow;
	verify = verify;
}