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

local e = _G.PolarisNav

local Selection = game:GetService 'Selection'

local component = e.Roact.PureComponent:extend(script.Name)

local keep_only = {}
function keep_only.Class(objs, value)
	for i, obj in next, objs do
		if not obj:IsA(value) then
			objs[i] = nil
		end
	end
end
function keep_only.Name(objs, value)
	for i, obj in next, objs do
		if obj.Name ~= value then
			objs[i] = nil
		end
	end
end
function keep_only.Attribute(objs, value)
	for i, obj in next, objs do
		if not obj:GetAttribute(value) then
			objs[i] = nil
		end
	end
end

local remove_only = {}
function remove_only.Class(objs, value)
	local cache = {}
	for i, obj in next, objs do
		local root = obj
		local cr = cache[root]
		while root.Parent ~= workspace do
			if cr ~= nil then
				break
			end
			root = root.Parent
			cr = cache[root]
		end
		if not cr then
			if cr == false or root:FindFirstChildOfClass(value, true) then
				cache[root] = false
				objs[i] = nil
			else
				cache[root] = true
			end
		end
	end
end
function remove_only.Humanoids(objs)
	remove_only.Class(objs, 'Humanoid')
end
function remove_only.Tools(objs)
	remove_only.Class(objs, 'Tool')
end
function remove_only.Unanchored(objs)
	for i, obj in next, objs do
		if not obj.Anchored then
			objs[i] = nil
		end
	end
end
function remove_only.Uncollidable(objs)
	for i, obj in next, objs do
		if not obj.CanCollide then
			objs[i] = nil
		end
	end
end

local function default_filter(obj)
	return obj:IsA 'BasePart' and not (
		obj.ClassName == 'Terrain' or
		obj.ClassName == 'MeshPart' or
		obj:IsA 'PartOperation'
	)
end
local function get_all(root, results)
	if default_filter(root) then
		results[#results + 1] = root
	end
	for i, child in ipairs(root:GetDescendants()) do
		if default_filter(child) then
			results[#results + 1] = child
		end
	end
	return results
end
local function apply_default(objs)
	for i, obj in next, objs do
		if not default_filter(obj) then
			objs[i] = nil
		end
	end
end

local function condense(t)
	local new = {}
	for i, v in next, t do
		new[#new + 1] = v
	end
	return new
end

local function select(include, without)
	local objs = get_all(workspace, {})
	for k, v in next, include do
		keep_only[k](objs, v)
	end
	for k in next, without do
		remove_only[k](objs)
	end
	objs = condense(objs)
	Selection:Add(objs)
end

local function deselect(include, without)
	local objs = Selection:Get()
	for k, v in next, include do
		keep_only[k](objs, v)
	end
	for k in next, without do
		remove_only[k](objs)
	end
	objs = condense(objs)
	Selection:Remove(objs)
end

function component:init(props)
	self.filter = {};
	self.include = {};
end

function component:render()
	return e.Context({
		Name = script.Name;
	}, {
		e.Line {
			e.TLabel {
				Text = 'Select the parts to generate the navigation mesh with. You may use the filters below to automatically select or deselect parts.';
				Size = UDim2.new(1, 0, 0, 0);
				AutomaticSize = Enum.AutomaticSize.Y;
			};

			e.Centered {
				e.TButton {
					Text = 'Cancel';
					Size = UDim2.new(0, 100, 0, 30);
					[e.Roact.Event.Activated] = e.bind(e.go.mode_set, 'Edit')
				};

				e.MainTButton {
					Text = 'Continue';
					Size = UDim2.new(0, 100, 0, 30);
					[e.Roact.Event.Activated] = function()
						local objs = Selection:Get()
						apply_default(objs)
						e.go.mode_set 'Generate_Params'
						e.go.objects_set(condense(objs));
						Selection:Set {}
					end;
				};

				e.UIListLayout {
					FillDirection = Enum.FillDirection.Horizontal;
					Padding = UDim.new(0, 20);
				};
			};

			e.UIPadding {
				PaddingTop = UDim.new(0, 20);
				PaddingRight = UDim.new(0, 20);
				PaddingLeft = UDim.new(0, 20);
			};

			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 20);
			};
		};

		e.Rows {
			Name = 'All with';
			data = self.include;
			rows = {
				{'Class', 'BasePart'};
				{'Name', 'Mesh'};
				{'Attribute', 'Walkable'};
			};
		};

		e.Rows {
			Name = 'Without any';
			data = self.filter;
			rows = {
				{'Humanoids'};
				{'Tools'};
				{'Unanchored'};
				{'Uncollidable'};
			};
		};

		e.Centered {
			e.TButton {
				Text = 'Deselect';
				Size = UDim2.new(0, 100, 0, 30);
				[e.Roact.Event.Activated] = function(obj, input, clicks)
					deselect(self.include, self.filter)
				end;
			};
			e.TButton {
				Text = 'Select';
				Size = UDim2.new(0, 100, 0, 30);
				[e.Roact.Event.Activated] = function(obj, input, clicks)
					select(self.include, self.filter)
				end;
			};

			e.UIListLayout {
				FillDirection = Enum.FillDirection.Horizontal;
				Padding = UDim.new(0, 20);
			};
		};

		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
			Padding = UDim.new(0, 20);
		};
	})
end

return component