
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
local Point = e.Point
local Surface = e.Surface
local Connection = e.Connection
local CConnection = e.CConnection
local Mesh = e.Mesh



local Ref_MT = {};
local F = {
	_VERSION = 2;
	ID = {};
	V3 = {};
	Byte = {};
	Double = {};
	Int = {};
	String = {};
	Any = {};
	Bool = {};
	Ref = {};
}
setmetatable(F.Ref, Ref_MT);

function F.map(k_format, v_format)
	return {
		type = 'map';
		k_format = k_format;
		v_format = v_format;
	}
end

function F.list(v_format, key)
	return {
		type = 'list';
		v_format = v_format;
		key = key;
	}
end

function F.union(...)
	return {
		type = 'union';
		...
	}
end

function F.struct(fields)
	return {
		type = 'struct';
		fields = fields
	}
end

function F.konst(value, v_format, is_serialized)
	return {
		type = 'konst';
		value = value;
		v_format = v_format;
		is_serialized = is_serialized;
	}
end

function F.save(name, v_format)
	return {
		type = 'save';
		name = name;
		v_format = v_format;
	}
end

function F.enable_if(cond, v_format)
	return {
		type = 'enable_if';
		cond = cond;
		v_format = v_format;
	}
end

function F.format(name, t)
	t.name = name
	e[name].format = t
end

function F.new(name, t)
	t.name = name
	F[name] = t
end

function Ref_MT:__index(name)
	local v = {
		type = 'ref';
		of = name;
	}
	self[name] = v
	return v
end

local function req_v(v)
	local function cond(data, i, context)
		return context.version >= v
	end
	return function(format)
		return F.enable_if(cond, format)
	end
end

local V2 = req_v(2)

local function req_v2(data, i, context)
	return context.version >= 2
end

F.format('Point', F.struct{
	{id = F.ID};
	{v3 = F.V3};
	{ptype = F.Byte};
})
F.new('PointSight', F.map(F.Ref.Points, F.Double))
F.format('Surface', F.union(
	F.list(F.Ref.Points),
	F.struct{
		{id = F.ID};
		{c_conns = F.map(F.Ref.Points, F.Ref.CConns)};
	}
))
F.format('Connection', F.struct{
	{action = F.Int};
	{fromID = F.Int};
	{toID = F.Int};
	{i1 = F.Int};
	{i2 = F.Int};
	{j1 = F.Int};
	{j2 = F.Int};
	{t1 = F.Double};
	{t2 = F.Double};
	{u1 = F.Double};
	{u2 = F.Double};
})
F.format('CConnection', F.struct{
	{type = F.String};
	{bidirectional = F.Bool};
	{at = F.map(F.Ref.Points, F.konst(true, F.Bool, false))};
	{to = F.map(F.Ref.Points, F.konst(true, F.Bool, false))};
})
F.format('Mesh', F.struct{
	{Name = F.String};
	{Visible = F.Bool};
	{points = F.list(Point, 'Points')};
	{c_conns = V2(F.list(CConnection, 'CConns'))};
	{surfaces = F.list(Surface, 'Surfaces')};
	{connections = F.list(Connection)};
})

F.new('MeshSave', F.struct{
	{version = F.save(
		'version',
		F.konst(F._VERSION, F.Int, true)
	)};
	{mesh = Mesh};
})
F.new('MeshReq', F.struct{
	{version = F.save(
		'version',
		F.konst(F._VERSION, F.Int, true)
	)};
	{params = F.map(F.String, F.Any)};
	{mesh = Mesh};
})

return F