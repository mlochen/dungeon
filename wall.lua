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

function createWall(pos, direction)
    local w = {}
    w.p1 = pos

    if direction == "n" or direction == "s" then
        w.p2 = pos + Vec2D.new(1, 0)
        w.center = pos + Vec2D.new(0.5, 0)
    elseif direction == "w" or direction == "e" then
        w.p2 = pos + Vec2D.new(0, 1)
        w.center = pos + Vec2D.new(0, 0.5)
    end

    w.height = 1.4
    w.face = direction

    if direction == "n" then
        w.color = {r = 0.3, g = 0.05, b = 0}
    elseif direction == "w" then
        w.color = {r = 0.4, g = 0.15, b = 0.02}
    elseif direction == "e" then
        w.color = {r = 0.35, g = 0.1, b = 0.01}
    elseif direction == "s" then
        w.color = {r = 0.45, g = 0.2, b = 0.03}
    end

    w.type = "w"
    return w
end
