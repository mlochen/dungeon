-- Copyright (C) 2019 Marco Lochen

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

function createWall(x, y, direction)
	w = {}
	w.x1 = x
	w.y1 = y

	if direction == "n" or direction == "s" then
		w.x2 = x + 1
		w.y2 = y
		w.cx = x + 0.5
		w.cy = y
	elseif direction == "w" or direction == "e" then
		w.x2 = x
		w.y2 = y + 1
		w.cx = x
		w.cy = y + 0.5
	end

	w.height = 1.4
	w.face = direction

	if direction == "n" then
		w.color = {r = 0.6, g = 0.1, b = 0}
	elseif direction == "w" then
		w.color = {r = 0.8, g = 0.3, b = 0.2}
	elseif direction == "e" then
		w.color = {r = 0.7, g = 0.2, b = 0.1}
	elseif direction == "s" then
		w.color = {r = 0.9, g = 0.4, b = 0.3}
	end

	w.type = "w"
	return w
end
