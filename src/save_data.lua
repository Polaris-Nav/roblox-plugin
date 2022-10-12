
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


local F = e.format
local util = e.util

util.d2b = e.ieee754.double2bin;

local function a(to, str)
	to[#to + 1] = str
	if to.size then
		to.size = to.size + #str
	end
end

function util.i2b(x)
	local bytes = {nil, nil, nil, nil}
	for i = 1, 4 do
		local byte = x % 256
		x = (x - byte) / 256
		bytes[i] = byte
	end


	return string.char(table.unpack(bytes))

end

function util.i642b(x)
	local bytes = {nil, nil, nil, nil, nil, nil, nil, nil}
	for i = 1, 8 do
		local byte = x % 256
		x = (x - byte) / 256
		bytes[i] = byte
	end


	return string.char(table.unpack(bytes))

end

function util.v2b(v)
	local s = table.concat {
		util.d2b(v.X),
		util.d2b(v.Y),
		util.d2b(v.Z)
	}

	return s
end

function util.s2b(s)
	return util.i2b(#s) .. s
end

function util.a2b(v)
	local ty = type(v)
	if ty == 'string' then
		return string.char(0) .. util.s2b(v)
	elseif ty == 'number' then
		return string.char(1) .. util.d2b(v)
	end
end

function util.encode(value)
	e:load 'zero_encoding'
	return util.encode_zeros(e.LibDeflate:CompressDeflate(value, {level = 9}))
end

function F.String:save(data)
	return a(data, util.s2b(self))
end
function F.Bool:save(data)
	return a(data, self
		and string.char(1)
		or string.char(0))
end
function F.V3:save(data)
	return a(data, util.v2b(self))
end

function F.Byte:save(data)
	return a(data, string.char(self))
end

function F.Double:save(data)
	return a(data, util.d2b(self))
end

function F.Int:save(data)
	return a(data, util.i2b(self))
end

function F.Int64:save(data)
	return a(data, util.i642b(self))
end

function F.Any:save(data)
	return a(data, util.a2b(self))
end

function util.save(data, obj, format, context)
	-- custom types have a "format" property
	format = format.format or format



	if format.type then
		if format.type == 'ref' then
			a(data, util.i2b(obj.id))
		elseif format.type == 'konst' then
			if format.is_serialized then
				util.save(data, format.value, format.v_format, context)
			end
		elseif format.type == 'save' then
			util.save(data, obj, format.v_format, context)
		elseif format.type == 'enable_if' then
			util.save(data, obj, format.v_format, context)
		elseif format.type == 'union' then
			for j, v_format in ipairs(format) do
				util.save(data, obj, v_format, context)
			end
		elseif format.type == 'struct' then
			for j, field in ipairs(format.fields) do
				local k, v = next(field)

				util.save(data, obj[k], v, context)
			end
		elseif format.type == 'array' then
			local v_format = format.v_format
			for i = 1, format.len do
				util.save(data, obj[i], v_format, context)
			end
		else
			local i, n = #data + 1, 0
			data[i] = ''
			if format.type == 'list' then
				local v_format = format.v_format
				n = #obj
				for i, v in ipairs(obj) do
					util.save(data, v, v_format, context)
				end
			elseif format.type == 'map' then
				local k_format = format.k_format
				local v_format = format.v_format
				for k, v in next, obj do
					n = n + 1
					util.save(data, k, k_format, context)
					util.save(data, v, v_format, context)
				end
			else
				print('unknown format type:', format.type)
			end
			data[i] = util.i2b(n)
		end
	end

	if format.save then


		format.save(obj, data, context)
	end


end

return true