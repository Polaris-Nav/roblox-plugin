
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


local util = e.util

local special = string.char(255)
function util.encode_zeros(value)
	local data = {}
	local i = 1
	local n = #value
	while i <= n do
		local b = value:byte(i)
		if b == 0 then
			local m = 1
			while i < n and m < 254 do
				if value:byte(i + 1) == 0 then
					m = m + 1
					i = i + 1
				else
					break
				end
			end
			data[#data + 1] = special
			data[#data + 1] = string.char(m)
		elseif b == 255 then
			data[#data + 1] = special
			data[#data + 1] = special
		else
			data[#data + 1] = string.char(b)
		end
		i = i + 1
	end
	return table.concat(data)
end

local null = string.char(0)
function util.decode_zeros(value)
	local data = {}
	local i = 1
	local n = #value
	while i <= n do
		local b = value:byte(i)
		if b == 255 then
			i = i + 1
			b = value:byte(i)
			if b == 255 then
				data[#data + 1] = special
			else
				for j = 1, b do
					data[#data + 1] = null
				end
			end
		else
			data[#data + 1] = string.char(b)
		end
		i = i + 1
	end
	return table.concat(data)
end

return true