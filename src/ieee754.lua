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

-- IEEE 754 double to binary
-- Does not support:
-- 	- signed zeros (treated as positive zero)
-- 	- NaNs (all types treated as quiet NaNs with payload = 1, 0/0 in Lua)
-- Both unsupported cases are due to being unable
-- distingush between the numbers in Lua.

-- encodings for special cases
local  inf = string.char(0x7F, 0xF0, 0, 0, 0, 0, 0, 0)
local ninf = string.char(0xFF, 0xF0, 0, 0, 0, 0, 0, 0)
local qnan = string.char(0x7F, 0xF8, 0, 0, 0, 0, 0, 1)
local nil_nan = string.char(0x7F, 0xF8, 0, 0, 0, 0, 0, 2)

-- converts a 16-bit integer
local function int2bytes(x, bytes)
	for i = 2, 1, -1 do
		local byte = x % 256
		x = (x - byte) / 256
		bytes[i] = byte
	end
end

-- converts a 7 byte fraction (6.5 is used in IEEE 754)
local function fraction2bytes(x, bytes)
	for i = 2, 8 do
		x = x * 256
		local f = x % 1
		bytes[i] = x - f
		x = f
	end
end

-- converts 6 bytes into a fraction as defined in IEE 754
local function bytes2fraction(bytes)
	local f = 0
	for i = 8, 3, -1 do
		f = (f + bytes[i]) / 256
	end
	return f
end

local zero = string.char(0, 0, 0, 0, 0, 0, 0, 0)
local function d2b(x)
	if type(x) ~= 'number' then
		return nil_nan
	end

	local _x = x
	if math.abs(x) == math.huge then
		return x < 0 and ninf or inf
	elseif x ~= x then
		return qnan
	elseif x == 0 then
		return zero
	end

	local bytes = {0, 0, 0, 0, 0, 0, 0, 0}
	local e = math.floor(math.log(math.abs(x), 2))
	int2bytes((e + 1023) * 16, bytes)

	-- does not preserve signed 0's
	if x < 0 then
		bytes[1] = bytes[1] + 128
		x = math.abs(x)
	end

	local upper = bytes[2]
	fraction2bytes((x / 2^e - 1) / 16, bytes)
	bytes[2] = bytes[2] + upper

	return string.char(unpack(bytes))
end

local l_float = {
	[ inf] = {math.huge};
	[ninf] = {-math.huge};
	[qnan] = {0/0};
	[nil_nan] = {nil};
}
local function b2d(b)
	if l_float[b] then
		return l_float[b][1]
	end

	local bytes = {b:byte(1, #b)}

	local e_u = bytes[1] % 128
	local f_u = bytes[2] % 16

	local e = e_u * 16 + (bytes[2] - f_u) / 16

	local f = bytes2fraction(bytes)
	f = (f + f_u) / 16

	-- allow subnormals
	local y
	if e > 0 then
		y = 2^(e-1023) * (1 + f)
	elseif f == 0 then
		y = 0
	else
		y = 2^-1022 * f
	end

	-- signed floats
	if bytes[1] - e_u == 128 then
		y = -y
	end

	return y
end

return {
	double2bin = d2b;
	bin2double = b2d;
}