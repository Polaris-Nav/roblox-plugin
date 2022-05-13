
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
local Point = e.Point
local Surface = e.Surface
local Connection = e.Connection
local CConnection = e.CConnection
local Mesh = e.Mesh

util.b2d = e.ieee754.bin2double;

function util.b2i(b)
	local bytes = {b:byte(1, #b)}
	local x = 0
	for i = 1, 4 do
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
	local t = {}
	for j = 1, i + 3 do
		t[j] = tostring(s:sub(j, j):byte())
	end
	n, i = util.read_i(s, i)
	local si = i
	i = i + n
	return s:sub(si, i - 1), i
end

function util.read_a(s, i)
	local ty
	ty, i = util.read_t(s, i)
	if ty == 0 then
		return util.read_s(s, i)
	elseif ty == 1 then
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

function Point.format:load(data, i, context)
	self.surfaces = {}
	self.lines_by_p = {}
	self.lines_by_s = {}
	self.sight, i = util.load(data, i, F.PointSight, context)
	for point, cost in next, self.sight do
		point.sight[self] = cost
	end
	return self, i
end

function Mesh.format:load(data, i)
	local reflexes = {}
	self.reflexes = reflexes
	for i, p in ipairs(self.points) do
		if p.ptype >= Point.REFLEX then
			reflexes[p] = true
		end
	end

	self.octree = e.Octree.Octree(0, 0, 0, 10);

	return self, i
end

function Surface.format:load(data, i, context)
	local a, b, c = self[1].v3, self[2].v3, self[3].v3
	self.normal = (c - a):Cross(b - a).Unit
	self.connections = {}
	self.adjacent = {}
	for i, p in ipairs(self) do
		p:add(self, i)
	end
	for p, c_conn in next, self.c_conns do
		p:add(self, c_conn)
	end
	return self, i
end

function CConnection.format:load(data, i, context)
	local action = e[self.type]
	setmetatable(self, action.MT)
	if self.save then
		local str
		str, i = util.read_s(data, i)
		self:load(str)
	end
	return self, i
end

function Mesh.load_dir(root)
	if root.ClassName ~= 'Folder' then
		return warn(root:GetFullName() .. ' is not a folder containing a saved mesh')
	end

	local saves = {}
	for i, save in ipairs(root:GetChildren()) do
		local num = tonumber(save.Name)
		if save.ClassName == 'StringValue' and num then
			saves[num] = save.Value
		end
	end
	if #saves == 0 then
		return warn(root:GetFullName() .. ' has no save data')
	end

	local data = util.decode(table.concat(saves))
	if not data then
		return warn(root:GetFullName() .. ': save appears to be corrupted')
	end

	return util.load(data, 1, F.MeshSave, {}).mesh
end

return true