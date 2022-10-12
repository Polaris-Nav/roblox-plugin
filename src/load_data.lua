
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


util.b2d = e.ieee754.bin2double


function util.b2i(b)
	local bytes = {b:byte(1, #b)}
	local x = 0
	for i = 4, 1, -1 do
		x = x * 256
		x = x + bytes[i]
	end



	return x
end

function util.b2i64(b)
	local bytes = {b:byte(1, #b)}
	local x = 0
	for i = 8, 1, -1 do
		x = x * 256
		x = x + bytes[i]
	end



	return x
end

function util.b2v(b)
	return Vector3.new(
		util.b2d(b:sub(1, 8)),
		util.b2d(b:sub(9, 16)),
		util.b2d(b:sub(17, 24))
	)
end

function util.read_i(s, i)
	return util.b2i(s:sub(i, i + 3)), i + 4
end

function util.read_i64(s, i)
	return util.b2i64(s:sub(i, i + 7)), i + 8
end

function util.read_d(s, i)
	return util.b2d(s:sub(i, i + 7)), i + 8
end

function util.read_v(s, i)
	return util.b2v(s:sub(i, i + 23)), i + 24
end

function util.read_t(s, i)
	return s:sub(i, i):byte(), i + 1
end

function util.read_s(s, i)
	local n
	n, i = util.read_i(s, i)
	local si = i
	i = i + n
	local str = s:sub(si, i - 1)

	return str, i
end

function util.read_a(s, i)
	local ty
	ty, i = util.read_t(s, i)
	if ty == 0 then
		print 'type = string'
		return util.read_s(s, i)
	elseif ty == 1 then
		print 'type = double'
		return util.read_d(s, i)
	else
		error('Received unknown field type: ' .. tostring(ty))
	end
end

function util.decode(value)
	e:load 'zero_encoding'
	return e.LibDeflate:DecompressDeflate(util.decode_zeros(value))
end

function util.decode_params(data, i)
	local fields = {}
	local n
	n, i = util.read_i(data, i)
	for j = 1, n do
		local name, value
		name, i = util.read_s(data, i)
		value, i = util.read_a(data, i)
		fields[name] = value
	end
	return fields, i
end

function F.String:load(data, i)
	return util.read_s(data, i)
end
function F.Bool:load(data, i)
	local b = data:sub(i, i)
	i = i + 1
	return b == string.char(1), i
end
function F.V3:load(data, i)
	return util.read_v(data, i)
end

function F.Byte:load(data, i)
	return data:sub(i, i):byte(), i + 1
end

function F.Double:load(data, i)
	return util.read_d(data, i)
end

function F.Int:load(data, i)
	return util.read_i(data, i)
end

function F.Int64:load(data, i)
	return util.read_i64(data, i)
end

function F.Any:load(data, i)
	return util.read_a(data, i)
end

function util.load(data, i, format, context)
	-- custom types have a "format" property
	local class
	if format.format then
		class = format
		format = format.format
	end



	local obj
	if format == F.ID then
		obj = #context[#context] + 1
	elseif format.type then
		if format.type == 'ref' then
			local id
			id, i = util.read_i(data, i)
			obj = context[format.of][id]
		elseif format.type == 'konst' then
			if format.is_serialized then
				obj, i = util.load(data, i, format.v_format, context)
			else
				obj = format.value
			end
		elseif format.type == 'save' then
			obj, i = util.load(data, i, format.v_format, context)
			context[format.name] = obj
		elseif format.type == 'enable_if' then
			if format.cond(data, i, context) then
				obj, i = util.load(data, i, format.v_format, context)
			end
		elseif format.type == 'union' then
			obj = {}
			for j, v_format in ipairs(format) do
				context.obj = obj
				obj, i = util.load(data, i, v_format, context)
			end

		else
			obj = context.obj
			if obj then
				context.obj = nil
			else
				obj = {}
			end

			if format.key then
				context[format.key] = obj
			end
			if format.type == 'struct' then
				for j, field in ipairs(format.fields) do
					local k, v_format = next(field)

					obj[k], i = util.load(data, i, v_format, context)
				end
			elseif format.type == 'array' then
				local v_format = format.v_format
				for j = 1, format.len do
					obj[j], i = util.load(data, i, v_format, context)
				end
			else
				local n
				n, i = util.read_i(data, i)
				local stack_id = #context + 1
				context[stack_id] = obj
				if format.type == 'list' then
					local v_format = format.v_format
					for j = 1, n do
						obj[j], i = util.load(data, i, v_format, context)
					end
				elseif format.type == 'map' then
					local k_format = format.k_format
					local v_format = format.v_format
					for j = 1, n do
						local k, v
						k, i = util.load(data, i, k_format, context)
						if k ~= nil then
							v, i = util.load(data, i, v_format, context)
							obj[k] = v

						end
					end
				else
					print('unknown format type:', format.type)
				end
				context[stack_id] = nil
			end
		end
	end

	if class and class.MT then
		setmetatable(obj, class.MT)
	end

	if format.load then


		obj, i = format.load(obj, data, i, context)

	end

	return obj, i
end

return true