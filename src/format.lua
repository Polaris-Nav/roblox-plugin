
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




local Ref_MT = {};
local F = {
	_VERSION = 2;
	ID = {};
	V3 = {};
	Byte = {};
	Double = {};
	Int = {};
	Int64 = {};
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

function F.array(len, v_format, key)
	return {
		type = 'array';
		v_format = v_format;
		len = len;
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

F.new('Challenge', F.struct{
	{signature = F.array(16, F.Byte)};
	{issued = F.Int64};
	{difficulty = F.Byte};
	{K00 = F.Int};
	{K01 = F.Int};
	{K10 = F.Int};
	{K11 = F.Int};
})

F.new('Solution', F.struct{
	{x = F.Int};
	{y = F.Int};
})

return F