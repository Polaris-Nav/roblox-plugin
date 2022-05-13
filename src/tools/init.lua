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

local CS = game:GetService 'CollectionService'
local UIS = game:GetService 'UserInputService'
local DS = game:GetService 'DraggerService'

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

		if state.mode then
			util.deactivate()
		end

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
			mode = nil;

			-- The shorcuts to activate modes
			shortcuts = {};

			-- Tracks the shortcuts that are currently pressed
			down = {};
			n_down = 0;

			-- Connections for all events
			connections = {};

			-- Root for created parts
			root = nil;

			-- PluginMouse currently in use
			mouse = nil;

			plugin = nil;

			-- Current Rodux store of the app
			store = nil;

			-- Tracks the last tool used
			last_mode = modes.PlaneSelector;

			modes = modes;

		-- Ephemoral state between tool changes
			-- Hovering state
			hovered = nil;

			-- Selection state
			selected = nil;

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
	
	local meshes = state.store:getState().meshes
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
		end

		if nxt_mode == nil then
			util.deactivate()
		elseif state.mode == nil then
			util.activate()
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

-- Handle keyboard input
local function onInput(obj, is_handled)
	if obj.UserInputType == Enum.UserInputType.Keyboard then
		if obj.UserInputState == Enum.UserInputState.Begin then
			state.n_down = state.n_down + 1
			state.down[obj.KeyCode] = state.n_down
		elseif obj.UserInputState == Enum.UserInputState.End then
			local nxt_mode = state.mode

			-- Unreported downs
			if not state.down[obj.KeyCode] then
				state.n_down = state.n_down + 1
				state.down[obj.KeyCode] = state.n_down
			end

			for combo, mode in next, state.shortcuts do
				if #combo == state.n_down then
					local found = true
					for j, code in ipairs(combo) do
						if j ~= state.down[code] then
							-- print('failed to find key ' .. tostring(code))
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

			state.down[obj.KeyCode] = nil
			state.n_down = state.n_down - 1
		end
	end
end

local function onMove()
	local t = state.mouse.Target
	if t and state.is_dragging then
		fire('drag', state.mouse.Hit.Position)
	elseif not (t and t:IsDescendantOf(state.root)) then
		fire 'unhover'
		return
	end

	if CS:HasTag(t.Parent, 'Polaris-Surface') then
		fire('hover', fire('get', t.Parent, state.mouse.Hit.Position))
	end
end

local function onDown()
	local t = state.mouse.Target
	if not t then
		fire 'deselect'
		return
	elseif not t:IsDescendantOf(state.root) then
		return
	end

	if CS:HasTag(t.Parent, 'Polaris-Surface') then
		fire('select', fire('get', t.Parent, state.mouse.Hit.Position))
	end
	fire('start_drag', t, state.mouse.Hit.Position)
end

local function onUp()
	if state.is_dragging then
		state.is_dragging = false
		fire 'stop_drag'
	end
end

function util.activate()
	state.plugin:Activate(true)
	local mouse = state.plugin:GetMouse()
	state.mouse = mouse
	state.connections.on_move = mouse.Move:Connect(onMove);
	state.connections.on_down = mouse.Button1Down:Connect(onDown);
	state.connections.on_up = mouse.Button1Up:Connect(onUp);
	state.connections.on_deactivated = state.plugin.Deactivation:Connect(util.onDeactivated);
end

function util.deactivate()
	--state.plugin:Deactivate()
	state.plugin:SelectRibbonTool(
		Enum.RibbonTool.Select,
		UDim2.new(0, 0, 0, 0)
	)
end

function util.onDeactivated()
	state.connections.on_deactivated:Disconnect()
	state.connections.on_deactivated = nil
	state.connections.on_move:Disconnect()
	state.connections.on_move = nil
	state.connections.on_down:Disconnect()
	state.connections.on_down = nil
	state.connections.on_up:Disconnect()
	state.connections.on_up = nil
	state.mouse:Destroy()
	state.mouse = nil
end

local function connect(plugin, store, root)
	reset()
	state.plugin = plugin
	state.store = store
	state.root = root
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