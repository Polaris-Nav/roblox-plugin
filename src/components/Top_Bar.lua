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

local is_hidden = {
	['Begin_Link'] = true,
	['Check_Link'] = true,
	['Refresh'] = true,
	['Login'] = true,
	['Welcome'] = true
}

local function checkandrun(props)
	if props.mode ~= 'Settings' then
		e.go.mode_set('Settings')
	else
		e.go.mode_set(props.previous_mode)
	end
end

local function component(props)
	local title = string.gsub(props.mode, '_', ' ')
	local elements = {
        e.TLabel({
            Text = title;
            TextSize = 19;
            TextColor3 = props.colors.BrightText;
            Size = UDim2.new(0, 0, 1, 0);
            Position = UDim2.new(0.5, 0, 0.5, 0);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.X;
        });
    }
	if not is_hidden[props.mode] then
        table.insert(elements, 1,
        e.ImageButton {
            BackgroundTransparency = 1;
            AnchorPoint = Vector2.new(0.5,0);
            Size = UDim2.new(0,24,0,24);
            Position = UDim2.new(1, -(26 / 2), 0, 0);
            Image = 'rbxassetid://3926307971';
            ImageRectSize = Vector2.new(36, 36);
            ImageRectOffset = Vector2.new(324, 124);
            ImageColor3 = props.colors.BrightText;
            [e.Roact.Event.Activated] = e.bind(checkandrun, props);
        })
	end
	return e.Pane({
		Size = UDim2.new(1, 0, 0, 27);
		Position = UDim2.new(0,0,0,-27);
		BackgroundColor3 = props.colors.MainBackground;
		BorderSizePixel = 1;
		BorderMode = Enum.BorderMode.Inset;
	}, elements);
end

return e.connect(function(state)
	return {
		colors = state.colors,
		mode = state.mode,
		previous_mode = state.previous_mode
	}
end)(component)