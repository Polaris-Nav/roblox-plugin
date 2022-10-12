
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


e:load 'mesh_format'
e:load 'load_data'

local F = e.format
local util = e.util

local Point = e.Point
local Surface = e.Surface
local Connection = e.Connection
local CConnection = e.CConnection
local Mesh = e.Mesh

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