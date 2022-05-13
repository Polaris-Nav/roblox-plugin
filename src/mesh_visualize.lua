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

local CS = game:GetService 'CollectionService'

local util = e.util
local Point = e.Point
local Surface = e.Surface
local Connection = e.Connection
local Mesh = e.Mesh

function util.create_point(pos, parent)
	local p = Instance.new("Part")
	p.Archivable = false
	p.Shape = Enum.PartType.Ball
	p.FormFactor = Enum.FormFactor.Custom
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.TopSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	p.Size = Vector3.new(1, 1, 1)
	p.Position = pos
	p.Parent = parent
	return p
end

function util.create_line(pos, dir, parent)
	local p = Instance.new("Part")
	p.Archivable = false
	p.FormFactor = Enum.FormFactor.Custom
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.TopSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	p.Color = Color3.new(1, 0, 0)
	p.Size = Vector3.new(0.05, 0.05, dir.Magnitude)
	p.CFrame = CFrame.new(pos + dir / 2, pos + dir)
	p.Parent = parent
	return p
end

local function spawnTrianglePart(parent)
	local p = Instance.new("WedgePart")
	p.Archivable = false
	p.Anchored = true
	p.BottomSurface = 0
	p.TopSurface = 0
	p.formFactor = "Custom"
	p.Size = Vector3.new(1,1,1)
	p.Parent = parent or game.Workspace
	return p
end

function util.create_triangle(a,b,c,parent,thickness)
	thickness = thickness or 0.002
	-- split triangle into two right angles on longest edge:
	local len_AB = (b - a).magnitude
	local len_BC = (c - b).magnitude
	local len_CA = (a - c).magnitude

	if (len_AB > len_BC) and (len_AB > len_CA) then
		a,c = c,a
		b,c = c,b
	elseif (len_CA > len_AB) and (len_CA > len_BC) then
		a,b = b,a
		b,c = c,b
	end

	local dot = (a - b):Dot(c - b)
	local split = b + (c-b).unit*dot/(c - b).magnitude

	-- get triangle sizes:
	local xA = thickness
	local yA = (split - a).magnitude
	local zA = (split - b).magnitude

	local xB = thickness
	local yB = yA
	local zB = (split - c).magnitude

	-- get unit directions:
	local diry = (a - split).unit
	local dirz = (c - split).unit
	local dirx = diry:Cross(dirz).unit

	-- get triangle centers:
	local posA = split + diry*yA/2 - dirz*zA/2
	local posB = split + diry*yB/2 + dirz*zB/2

	-- place parts:
	local partA = spawnTrianglePart(parent)
	partA.Name = "TrianglePart"
	partA.Size = Vector3.new(xA,yA,zA)
	partA.CFrame = CFrame.new(posA.x,posA.y,posA.z, dirx.x,diry.x,dirz.x, dirx.y,diry.y,dirz.y, dirx.z,diry.z,dirz.z)

	dirx = dirx * -1
	dirz = dirz * -1

	local partB = spawnTrianglePart(parent)
	partB.Name = "TrianglePart"
	partB.Size = Vector3.new(xB,yB,zB)
	partB.CFrame = CFrame.new(posB.x,posB.y,posB.z, dirx.x,diry.x,dirz.x, dirx.y,diry.y,dirz.y, dirx.z,diry.z,dirz.z)
end

function util.rnd_color()
	return Color3.new(
		math.random(),
		math.random(),
		math.random()
	)
end


local RED = Color3.new(1, 0, 0)
local GREEN = Color3.new(0, 1, 0)
local BLUE = Color3.new(0, 0, 1)
function Point:create(parent, props)
	if self.part and self.part.Parent then
		return
	end
	
	local p = Instance.new 'Part'
	p.Name = tostring(self.id)
	p.Archivable = false
	p.Shape = Enum.PartType.Ball
	p.FormFactor = Enum.FormFactor.Custom
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.TopSurface = Enum.SurfaceType.Smooth
	if self.ptype <= Point.MIDEXTERIOR then
		p.Color = GREEN
	elseif self.ptype >= Point.REFLEX then
		p.Color = RED
	else
		p.Color = BLUE
	end
	p.Anchored = true
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Position = self.v3
	self.part = p
	if props then
		self:set_props(props)
	end
	p.Parent = parent

	return p
end
function Point:update(v3)
	self.v3 = v3
	if self.part then
		self.part.Position = v3
	end
	for surface in next, self.surfaces do
		local con = surface.c_conns[self]
		if con then
			con:update()
		else
			surface:update()
		end
	end
end
function Point:set_props(props)
	local p = self.part
	for k, v in next, props do
		p[k] = v
	end
end
function Point:destroy()
	self.part:Destroy()
	self.part = nil
end

function Surface:create_points(parent, color)
	color = color or util.rnd_color()
	local model = Instance.new 'Folder'
	for i, point in ipairs(self) do
		point:create(model)
		point.part.Name = point.part.Name .. ' ' .. tostring(i)
	end
	for at, action in next, self.c_conns do
		at:create(model)
	end
	self.points = model
	model.Name = 'Points ' .. self.id
	model.Parent = parent
	CS:AddTag(model, 'Polaris-Mesh')
	return model
end

function Surface:create_surface(parent, color)
	color = color or util.rnd_color()
	local model = Instance.new 'Folder'
	model.Archivable = false
	local a, b, c = self[1].v3, self[2].v3, self[3].v3
	util.create_triangle(a, b, c, model, self.thickness)
	local center = a + b + c
	for i = 4, #self do
		b = c
		c = self[i].v3
		center = center + c
		util.create_triangle(a, b, c, model, self.thickness)
	end
	center = center / #self
	util.create_line(center, self.normal * 1, model)
	for i, p in ipairs(model:GetChildren()) do
		p.Color = color
		p.Transparency = 0.5
	end
	self.surface = model
	model.Name = 'Surface ' .. self.id
	model.Parent = parent
	CS:AddTag(model, 'Polaris-Surface')
	return model
end

function Surface:create_connections(parent, color)
	for i, con in ipairs(self.connections) do
		if con.fromID == self.id then
			con:create_bounds(parent, color)
		end
	end
end

function Surface:destroy_points()
	for i, p in ipairs(self) do
		p:destroy()
	end
	self.points:Destroy()
	self.points = nil
end

function Surface:destroy_surface()
	self.surface:Destroy()
	self.surface = nil
end

function Surface:update()
	-- TODO: runs checks
	if not self.surface then
		return
	end

	local example = self.surface:GetChildren()[1]
	local color = example.Color
	local trans = example.Transparency
	local parent = self.surface.Parent
	self:destroy_surface()
	self:create_surface(parent)
	self:set_props({
		Color = color;
		Transparency = trans;
	})
end

function Surface:set_props(props)
	for i, child in ipairs(self.surface:GetChildren()) do
		for k, v in next, props do
			child[k] = v
		end
	end
end

function Connection:create_bounds(parent, color)
	local sf = self.from
	local st = self.to
	local a = sf:get_p(self.i1, self.t1)
	local b = st:get_p(self.j1, self.u1)
	local c = sf:get_p(self.i2, self.t2)
	local d = st:get_p(self.j2, self.u2)

	local model = Instance.new 'Model'
	model.Name = 'Connection ' .. self.action .. ':' .. self.fromID .. '->' .. self.toID

	util.create_line(a, b - a, model)
	util.create_triangle(a, b, c, model)
	util.create_triangle(b, c, d, model)
	util.create_line(c, d - c, model)

	for i, child in ipairs(model:GetChildren()) do
		child.Color = color
		child.Transparency = 0.7
	end
	
	model.Parent = parent

	return model
end

function Mesh:create_surfaces(root, mesh_id, color_s)
	local folder = Instance.new 'Folder'
	folder.Name = 'Mesh ' .. mesh_id
	for i, surface in ipairs(self.surfaces) do
		surface:create_surface(folder, color_s)
		surface:create_points(folder, color_s)
	end

	for i, c_conn in ipairs(self.c_conns) do
		c_conn:create(folder)
	end

	-- create all connections
	-- for i, connection in ipairs(self.connections) do
	-- 	local c = connection:create_bounds(folder, color_c)
	-- 	CS:AddTag(c, 'Polaris-Mesh')
	-- end

	-- create all reflex connections
	-- for i, p1 in ipairs(self.points) do
	-- 	for p2, cost in next, p1.sight do
	-- 		local l = e.util.create_line(p1.v3, p2.v3 - p1.v3, folder)
	-- 		CS:AddTag(l, 'Polaris-Mesh')
	-- 	end
	-- end

	CS:AddTag(folder, 'Polaris-Mesh')
	folder.Parent = root
	self.folder = folder
	return folder
end

return true