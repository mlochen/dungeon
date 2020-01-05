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

Vec2D = {}

-- returns a string representation of a vector
function Vec2D.tostring(v)
    return "(" .. v.x .. ", " .. v.y .. ")"
end

-- checks two vectors for equality
function Vec2D.equal(v1, v2)
    return v1.x == v2.x and v1.y == v2.y
end

-- adds two vectors
function Vec2D.add(v1, v2)
    return Vec2D.new(v1.x + v2.x, v1.y + v2.y)
end

-- substracts two vectors
function Vec2D.sub(v1, v2)
    return Vec2D.new(v1.x - v2.x, v1.y - v2.y)
end

Vec2D.mt = {}
Vec2D.mt.__eq = Vec2D.equal
Vec2D.mt.__add = Vec2D.add
Vec2D.mt.__sub = Vec2D.sub
Vec2D.mt.__metatable = ""
Vec2D.mt.__tostring = Vec2D.tostring

function Vec2D.new(x, y)
    local v = {}
    setmetatable(v, Vec2D.mt)
    v.x = x
    v.y = y
    return v
end

-- normalizes a vector, if v has length 0 it returns itself
function Vec2D.normalize(v)
    local length = Vec2D.getLength(v)
    if (length == 0) then
        return Vec2D.new(v.x, v.y)
    else
        return Vec2D.new(v.x / length, v.y / length)
    end
end

-- multiplies a vector with a scalar
function Vec2D.mul(v, s)
    return Vec2D.new(v.x * s, v.y * s)
end

-- returns the dot product of two vectors
function Vec2D.dotProduct(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

-- returns a positive value if the angle between v1 and v2 is positive
-- and a negative value if the angle between v1 and v2 is negative
-- returns 0 if both vectors point in the same or opposite direction
function Vec2D.sideOf(v1, v2)
    return v1.x * v2.y - v1.y * v2.x
end

-- returns v2 rotated by the angle of v1
function Vec2D.rotateByVec(v1, v2)
    return Vec2D.rotate(v1, -Vec2D.getAngle(v2))
end

-- returns the distance between the two points pointed at by v1 and v2
function Vec2D.getDistance(v1, v2)
    return math.sqrt((v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2)
end

-- returns the length of a vector
function Vec2D.getLength(v)
    return math.sqrt(v.x ^ 2 + v.y ^ 2)
end

-- returns the angle the vector is pointing at (in radians)
-- the vector (1, 0) has an angle of 0 and (0, 1) of pi / 2
function Vec2D.getAngle(v)
    local a = math.pi / 2
    if (v.x ~= 0) then
        a = math.atan(v.y / v.x)
    end
    if v.x < 0 then
        a = math.pi + a
    end
    return a
end

-- returns a rotated a vector
function Vec2D.rotate(v, a)
    local x = math.cos(a) * v.x - math.sin(a) * v.y
    local y = math.sin(a) * v.x + math.cos(a) * v.y
    return Vec2D.new(x, y)
end

