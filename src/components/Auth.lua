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

local component = e.Roact.PureComponent:extend(script.Name)

local token_pattern = '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$'

function component:init()
	self.token = e.Roact.createRef()
end

function component:render()
	return e.Context({
		Name = 'Auth'
	}, {
		e.Pane({
			Size = UDim2.new(1, 0, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
		}, {
			e.Title {
				Text = 'Authentication';
			};
			e.Subtitle {
				Text = 'Enter your authentication token to gain access to Polaris-Nav\'s automatic mesh generator servers.';
			};
			e.Pane({
				Size = UDim2.new(1, 0, 0, 27);
			}, {
				e.TLabel {
					Text = 'Token';
					Size = UDim2.new(0, 100, 1, 0);
				};
				e.TBox {
					[e.Roact.Ref] = self.token;
					Size = UDim2.new(1, -120, 1, 0);
					Position = UDim2.new(0, 120, 0, 0);
					Text = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
				};
			});
			e.Pane({
				Size = UDim2.new(1, 0, 0, 27);
			}, {
				e.Pane({
					Size = UDim2.new(0, 0, 1, 0);
					AutomaticSize = Enum.AutomaticSize.X;
					AnchorPoint = Vector2.new(0.5, 0);
					Position = UDim2.new(0.5, 0, 0, 0);
				}, {
					e.TButton {
						Text = 'Skip';
						Size = UDim2.new(0, 100, 1, 0);
						[e.Roact.Event.Activated] = function(obj, input, clicks)
							e.requireConfirm {
								text = 'If you do no enter a token, you will not be able to automatically generate a mesh. You will have to manually create your mesh.';
								onConfirm = {
									type = 'authorized';
								};
							}
						end;
					};
					e.MainTButton {
						Text = 'Continue';
						Size = UDim2.new(0, 100, 1, 0);
						[e.Roact.Event.Activated] = function(obj, input, clicks)
							local token = self.token:getValue().Text
								:match(token_pattern)
							if not token then
								e.error 'Please enter a valid security token. If you do not have one, contact the developer for one.'
							else
								self.props.setToken {
									token = token
								}
								self.props.authorized {}
							end
						end;
					};
					e.UIListLayout {
						FillDirection = Enum.FillDirection.Horizontal;
						Padding = UDim.new(0, 20);
					};
				});
			});
			e.UIPadding {
				PaddingLeft = UDim.new(0, 20);
				PaddingRight = UDim.new(0, 20);
			};
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 20);
			};
		})
	})
end

function e.reducers.authorized(action, old, new)
	if not old.mode == 'Auth' then
		return old
	elseif #old.meshes == 0 then
		new.mode = 'Generate'
	else
		new.mode = 'Edit'
		e.reducers.loadMeshes({}, old, new)
	end
	return new
end

function e.reducers.setToken(action, old, new)
	new.token = action.token
	e.plugin:SetSetting('token', action.token)
	return new
end

return component