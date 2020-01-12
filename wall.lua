-- Copyright (C) 2020 Marco Lochen

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
    w.pos = pos
    w.p1 = pos - Vec2D.mul(direction, 0.5)
    w.p2 = pos + Vec2D.mul(direction, 0.5)
    w.direction = direction
    w.normal = Vec2D.rotate(direction, math.pi / 2)
    w.height = 1.4
    w.type = "w"

    local light = Vec2D.normalize(Vec2D.new(-3, -1))
    local color = {r = 0.3, g = 0.15, b = 0.03}
    local colorfactor = math.acos(Vec2D.dotProduct(light, direction)) / math.pi
    w.color = {}
    w.color.r = color.r * 0.25 + color.r * colorfactor * 0.75
    w.color.g = color.g * 0.25 + color.g * colorfactor * 0.75
    w.color.b = color.b * 0.25 + color.b * colorfactor * 0.75

    return w
end
