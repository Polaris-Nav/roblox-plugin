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

local CS = game:GetService 'CollectionService'
local UIS = game:GetService 'UserInputService'
local DS = game:GetService 'DraggerService'
local SS = game:GetService 'Selection'

local modes = {
	PlaneSelector 	= require(script.PlaneSelector);
	LineSelector 	= require(script.LineSelector);
	PointSelector 	= require(script.PointSelector);
	ManualConnector = require(script.ManualConnector);
}

-- All shared state between tools
local state

-- Calls [name] method on the current mode, or does nothing
local function fire(name, ...)
	if not state.mode then
		return
	end

	local f = state.mode[name]
	if f then
		return f(state, ...)
	end
end

-- utility functions shared with all tools
local util = {}

-- Initial state and safe reset
local function reset()

	-- clear the state
	if state then
		fire 'unhover'
		fire 'deselect'
		e.go.selection_clear()

		-- disconnect the connections, or roblox continues to call handlers
		for name, connection in next, state.connections do
			connection:Disconnect()
			state.connections[name] = nil
		end
	end

	-- create a new state
	state = {
		-- Persistant state between tool changes
			fire = fire;
			util = util;

			-- The current mode that defines connections
			mode = modes.PlaneSelector;

			-- The shorcuts to activate modes
			shortcuts = {};

			-- Tracks the shortcuts that are currently pressed
			down = {};
			n_down = 0;

			-- Connections for all events
			connections = {};

			-- Root for created parts
			root = nil;

			-- RaycastParams for finding if rays intersect the meshes
			raycast_params = nil;

			plugin = nil;

			-- Current Rodux store of the app
			store = nil;

			-- Tracks the last tool used
			last_mode = modes.PlaneSelector;

			modes = modes;

		-- Ephemoral state between tool changes
			-- Hovering state
			hovered = nil;

			-- If a point existed before hovering
			existed_h = nil;

			-- If a point existed before selecting
			existed_s = nil;

			-- Various dragging states
			is_dragging = false;
			is_snapped = false;
			offset = nil;
			snap_pos = nil;
	}

	-- dynamically generated state
	for name, api in next, modes do
		if api.shortcut then
			state.shortcuts[api.shortcut] = api
		end
	end
end

function util.find(target)
	local surface_id = target.Name:match '^Surface (%d+)$'
	if not surface_id then
		return -- It is a connection
	end
	surface_id = tonumber(surface_id)

	local mesh_id = tonumber(target.Parent.Name:match '^Mesh (%d+)$')
	
	local store_state = state.store:getState()
	local meshes = store_state.meshes
	local mesh = meshes[mesh_id]
	
	if not mesh then
		return nil
	end

	local surface = mesh.surfaces[surface_id]

	return mesh, surface
end

function util.set_mode(nxt_mode)
	if nxt_mode ~= state.mode then
		if state.mode then
			fire 'unhover'
			fire 'deselect'
			e.go.selection_clear()
		end

		state.last_mode = state.mode
		state.mode = nxt_mode
	end
end

function util.reset_mode()
	local mode = state.mode
	state.mode = state.last_mode
	state.last_mode = mode
end

local function create_raycast_params()
	local p = RaycastParams.new()
	p.FilterDescendantsInstances = {}
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.IgnoreWater = true
	p.RespectCanCollide = false
	return p
end

local function get_hit(view_pos)
	local camera = workspace.CurrentCamera
	local ray = camera:ViewportPointToRay(view_pos.X, view_pos.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 5000, state.raycast_params)
	if not result then
		return
	else
		return result.Instance, result.Position
	end
end

local function onMove(input)
	local t, world_pos = get_hit(input.Position)
	if t and state.is_dragging then
		fire('drag', world_pos)
	elseif not (t and t:IsDescendantOf(state.root)) then
		fire 'unhover'
		return
	end

	if CS:HasTag(t.Parent, 'Polaris-Surface') then
		local objs = fire('get', t.Parent, world_pos)
		if not objs then
			return
		end
		for i, obj in objs do
			fire('hover', obj)
		end
	end
end

local function onDown(input)
	local t, world_pos = get_hit(input.Position)
	if not t or not t:IsDescendantOf(state.root) then
		return
	end
	fire('start_drag', t, world_pos)
end

local function onUp(input)
	if state.is_dragging then
		state.is_dragging = false
		fire 'stop_drag'
	end
end

local function onClick(input)
	local t, world_pos = get_hit(input.Position)
	if not t then
		fire 'deselect'
		e.go.selection_clear()
		return
	elseif not t:IsDescendantOf(state.root) then
		return
	end

	local old_selection = e.store:getState().selection
	if not (
		UIS:IsKeyDown(Enum.KeyCode.LeftShift) or
		UIS:IsKeyDown(Enum.KeyCode.RightShift)
	) then
		fire 'deselect'
		e.go.selection_clear()
	end

	if CS:HasTag(t.Parent, 'Polaris-Surface') then
		local objs = fire('get', t.Parent, world_pos)
		if not objs then
			return
		end
		local update = {}
		for i, obj in objs do
			if old_selection[obj] then
				update[obj] = false
				fire('deselect', obj)
			else
				update[obj] = true
				fire('select', obj)
			end
		end
		e.go.selection_update(update)
	end
end

local function onPress(input)
	state.n_down = state.n_down + 1
	state.down[input.KeyCode] = state.n_down
end

local function onRelease(input)
	local nxt_mode = state.mode

	-- Unreported downs
	if not state.down[input.KeyCode] then
		state.n_down = state.n_down + 1
		state.down[input.KeyCode] = state.n_down
	end

	for combo, mode in next, state.shortcuts do
		if #combo == state.n_down then
			local found = true
			for j, code in ipairs(combo) do
				if j ~= state.down[code] then
					found = false
					break
				end
			end
			if found then
				if state.mode == mode then
					util.set_mode(nil)
				else
					util.set_mode(mode)
				end
			end
		end
	end

	state.down[input.KeyCode] = nil
	state.n_down = state.n_down - 1
end

-- Handle keyboard input
local left_down_no_move = false
local right_down_no_move = false
local ignore_left_click = false
local function onInput(input, is_handled)
	local t = input.UserInputType
	local s = input.UserInputState
	if t == Enum.UserInputType.Keyboard then
		if input.UserInputState == Enum.UserInputState.Begin then
			onPress(input)
		elseif input.UserInputState == Enum.UserInputState.End then
			onRelease(input)
		end
	elseif t == Enum.UserInputType.MouseMovement then
		right_down_no_move = false
		left_down_no_move = false
		onMove(input)
	elseif t == Enum.UserInputType.MouseButton1 then
		if input.UserInputState == Enum.UserInputState.Begin then
			if not ignore_left_click then
				left_down_no_move = true
				onDown(input)
			end
		elseif input.UserInputState == Enum.UserInputState.End then
			if not ignore_left_click then
				onUp(input)
				if left_down_no_move then
					onClick(input)
					left_down_no_move = false
				end
			end
			ignore_left_click = false
		end
	elseif t == Enum.UserInputType.MouseButton2 then
		if input.UserInputState == Enum.UserInputState.Begin then
			right_down_no_move = true
		elseif input.UserInputState == Enum.UserInputState.End then
			if right_down_no_move then
				ignore_left_click = true
				right_down_no_move = false
			end
		end
	end
end

local function connect(plugin, store, root)
	reset()
	state.plugin = plugin
	state.store = store
	state.root = root
	state.raycast_params = create_raycast_params()
	state.connections = {
		on_began = UIS.InputBegan:Connect(onInput);
		on_changed = UIS.InputChanged:Connect(onInput);
		on_ended = UIS.InputEnded:Connect(onInput);
	}
end

return {
	connect = connect;
	disconnect = reset;
}