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

local component = e.Roact.PureComponent:extend(script.Name)
local CS = game:GetService 'CollectionService'
local TS = game:GetService 'TextService'

local function sort_by_priority(a, b)
	return a.priority < b.priority
end

function component:render()
	local mesh_rows = {}
	local selection = self.props.selection
	for i, mesh in ipairs(self.props.meshes) do
		mesh_rows[i] = e.RowTButton {
			is_selected = selection[mesh] or false;
			Text = mesh.Name;
			onActivated = function()
				e.go.selection_update {
					[mesh] = not selection[mesh];
				}
			end;
		}
	end
	mesh_rows[#mesh_rows + 1] = e.UIGridLayout {
		CellPadding = UDim2.new(0, 10, 0, 10);
		CellSize = UDim2.new(0, 120, 0, 25);
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		VerticalAlignment = Enum.VerticalAlignment.Top;
	}
	mesh_rows[#mesh_rows + 1] = e.UIPadding {
		PaddingTop = UDim.new(0, 10);
		PaddingLeft = UDim.new(0, 10);
		PaddingRight = UDim.new(0, 10);
		PaddingBottom = UDim.new(0, 10);
	}

	local sections = {}
	for name, cact in next, e.context_actions do
		if cact.is_relevant() then
			local sect = sections[cact.section]
			if not sect then
				sect = {
					button = {};
					property = {};
				}
				sections[cact.section] = sect
			end
			sect = sect[cact.type]
			sect[#sect + 1] = cact
		end
	end

	local max_width = self.props.width
	local font_enum = Enum.Font.SourceSans
	local font = Font.fromEnum(font_enum)

	local children = {}
	for name, types in next, sections do
		local sect_children = {
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 10);
				SortOrder = Enum.SortOrder.LayoutOrder;
			};
			e.UIPadding {
				PaddingTop = UDim.new(0, 10);
			};
		}
		local props = {}
		for i, cact in ipairs(types.property) do
			props[i] = e.Row {
				i = i;
				name = cact.name;
				hint = cact.hint;
				units = cact.units;
				path = cact.path;
				data = cact.data;
			};
		end
		if #props > 0 then
			props[#props + 1] = e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
			};
			sect_children[#sect_children + 1] = e.Line(props)
		end

		local line = {
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Horizontal;
				Padding = UDim.new(0, 10);
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				SortOrder = Enum.SortOrder.LayoutOrder;
			};
		}
		local remaining_width = max_width
		for i, cact in ipairs(types.button) do
			local params = Instance.new 'GetTextBoundsParams'
			params.Text = cact.name
			params.Font = font
			params.Size = 15
			params.Width = max_width
			local size = TS:GetTextBoundsAsync(params)

			local width = size.X + 10
			local height = size.Y + 10

			if width > remaining_width then
				remaining_width = max_width
				sect_children[#sect_children + 1] = e.Line(line)
				line = {
					e.UIListLayout {
						FillDirection = Enum.FillDirection.Horizontal;
						Padding = UDim.new(0, 10);
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						SortOrder = Enum.SortOrder.LayoutOrder;
					};
				}
			end

			remaining_width = remaining_width - width - 10

			line[#line + 1] = e.TButton {
				Text = cact.name;
				Font = font_enum;
				TextSize = 15;
				Size = UDim2.new(0, width, 0, height);
				LayoutOrder = cact.priority;
				[e.Roact.Event.Activated] = cact.on_action;
			};
		end
		if #line > 1 then
			sect_children[#sect_children + 1] = e.Line(line)
		end

		children[#children + 1] = e.Section({
			Name = name;
		}, {
			e.Pane({
				Size = UDim2.new(1, 0, 0, 50);
			}, sect_children)
		});
		children[#children + 1] = e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
		};
	end

	return e.Context({
		Name = script.Name;
	}, {
		e.Line {
			e.HeaderBackground({}, {
				e.HeaderLabel {
					Text = "Discord";
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70, 0, 1);
					TextSize = 10;
					Text = 'Join';
					[e.Roact.Event.Activated] = e.op.invite_discord;
				};
			})
		},
		e.Line {
			e.HeaderBackground({}, {
				e.HeaderLabel {
					Text = 'Account';
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70 -20 -70, 0, 1);
					TextSize = 10;
					Text = 'Unlink';
					[e.Roact.Event.Activated] = e.op.unlink;
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70, 0, 1);
					TextSize = 10;
					Text = 'Logout';
					[e.Roact.Event.Activated] = e.op.logout;
				};
			});
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
			};
		};

		e.Line {
			e.HeaderBackground({}, {
				e.HeaderLabel {
					Text = 'Meshes';
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70 -20 -70, 0, 1);
					TextSize = 10;
					Text = 'New';
					[e.Roact.Event.Activated] = e.bind(e.go.mode_set, 'Generate');
				};
				e.TButton {
					Size = UDim2.new(0, 70, 1, -2);
					Position = UDim2.new(1, -70, 0, 1);
					TextSize = 10;
					Text = 'Load';
					[e.Roact.Event.Activated] = e.bind(e.go.mode_set, 'Load');
				};
			});
			e.Line(mesh_rows);
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
			};
		};

		e.Line(children);

		e.UIPadding {
			PaddingTop = UDim.new(0, 20);
			PaddingBottom = UDim.new(0, 20);
		};

		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
		};
	})
end

return e.connect(function(state, props)
	return {
		meshes = state.meshes;
		selection = state.selection;
		width = state.size.X;
	}
end)(component)