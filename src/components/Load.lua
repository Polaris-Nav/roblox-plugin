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

local component = e.Roact.PureComponent:extend(script.Name)

function component:render()
	local rows = {}
	for i, save in ipairs(self.props.saves) do
		rows[i] = e.TButton {
			TextSize = 15;
			Font = Enum.Font.SourceSans;
			Size = UDim2.new(1, 0, 0, 27);
			Text = save.Name;
			[e.Roact.Event.Activated] = function(obj)
				e.go.mode_set 'Edit'
				return e.go.meshes_add(e.Mesh.load_dir(save))
			end;
		}
	end

	rows[#rows + 1] = e.UIListLayout {
		FillDirection = Enum.FillDirection.Vertical;
	}

	return e.Context({
		Name = script.Name;
	}, {
		e.Centered {
			e.TLabel {
				Text = 'Select which mesh you would like to load.';
				AutomaticSize = Enum.AutomaticSize.XY;
			};
			e.UIPadding {
				PaddingTop = UDim.new(0, 10);
				PaddingLeft = UDim.new(0, 10);
				PaddingRight = UDim.new(0, 10);
				PaddingBottom = UDim.new(0, 10);
			};
		};

		e.Line(rows);

		e.Centered {
			e.TButton {
				Text = 'Cancel';
				Size = UDim2.new(0, 100, 0, 30);
				[e.Roact.Event.Activated] = function()
					e.go.mode_set 'Edit'
				end;
			};

			e.TButton {
				Text = 'Refresh';
				Size = UDim2.new(0, 100, 0, 30);
				[e.Roact.Event.Activated] = function()
					e.go.saves_refresh()
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

return e.connect(function(state, props)
	return {
		saves = state.saves;
	}
end)(component)