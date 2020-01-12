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

require("enemy")
require("player")
require("switch")
require("wall")
require("vec2D")

World_model = {}
World_model.__index = World_model

function World_model.new(level)
    local world = {}
    setmetatable(world, World_model)
    world.player = nil
    world.enemies = {}
    world.characters = {}
    world.walls = {}
    world.switches = {}

    local worldString = level.worldString
    local w = level.worldWidth
    local h = #worldString / w

    -- find walls
    for y = 0, h - 2 do
        for x = 0, w - 2 do
            local i = x + y * w
            local c1 = string.sub(worldString, i + 1, i + 1)
            local c2 = string.sub(worldString, i + 2, i + 2)
            local c3 = string.sub(worldString, i + 1 + w, i + 1 + w)

            if c1 ~= "#" and c2 == "#" then
                local wallID = (x * 2^16) + (y * 2^8) + 0
                local wallPos = Vec2D.new(x + 1, y + 0.5)
                local wallDir = Vec2D.new(0, 1)
                world.walls[wallID] = createWall(wallPos, wallDir)
            elseif c1 == "#" and c2 ~= "#" then
                local wallID = (x * 2^16) + (y * 2^8) + 1
                local wallPos = Vec2D.new(x + 1, y + 0.5)
                local wallDir = Vec2D.new(0, -1)
                world.walls[wallID] = createWall(wallPos, wallDir)
            end
            if c1 ~= "#" and c3 == "#" then
                local wallID = (x * 2^16) + (y * 2^8) + 2
                local wallPos = Vec2D.new(x + 0.5, y + 1)
                local wallDir = Vec2D.new(-1, 0)
                world.walls[wallID] = createWall(wallPos, wallDir)
            elseif c1 == "#" and c3 ~= "#" then
                local wallID = (x * 2^16) + (y * 2^8) + 3
                local wallPos = Vec2D.new(x + 0.5, y + 1)
                local wallDir = Vec2D.new(1, 0)
                world.walls[wallID] = createWall(wallPos, wallDir)
            end
        end
    end

    -- find player, enemies and switches
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local i = x + y * w
            local c = string.sub(worldString, i + 1, i + 1)

            if c == "p" then
                world.player = Player:new(Vec2D.new(x + 0.5, y + 0.5), world)
                table.insert(world.characters, world.player)
            elseif c == "e" then
                local enemy = Enemy:new(Vec2D.new(x + 0.5, y + 0.5), world)
                table.insert(world.enemies, enemy)
                table.insert(world.characters, enemy)
            elseif c == "s" or c == "g" then
                local switch = Switch:new(Vec2D.new(x, y), c)
                table.insert(world.switches, switch)
            end
        end
    end

    return world, world.player
end

function World_model:update(dt, mouseDelta)
    -- update characters
    for _, c in pairs(self.characters) do
        c:update(dt, mouseDelta)
        if c.alive == true then
            for _, otherCharacter in pairs(self.characters) do
                if c ~= otherCharacter and otherCharacter.alive == true then
                    c.pos = World_model.characterCollision(c, otherCharacter)
                end
            end
            local cx = math.floor(c.pos.x)
            local cy = math.floor(c.pos.y)
            for wx = cx - 1, cx + 1 do
                for wy = cy - 1, cy + 1 do
                    for wf = 0, 3 do
                        local wallID = (wx * 2^16) + (wy * 2^8) + wf
                        if self.walls[wallID] ~= nil then
                            c.pos = World_model.wallCollision(c, self.walls[wallID])
                        end
                    end
                end
            end
        end
    end

    -- update switches
    local goalActive = true
    local goal = nil
    for _, switch in pairs(self.switches) do
        switch:update(dt, self.player)
        if switch.type == "s" and switch.pushed == false then
            goalActive = false
        elseif switch.type == "g" then
            goal = switch
        end
    end
    if goalActive == true then
        goal.active = true
    end
end

function World_model:getObjects()
    return self.player, self.walls, self.enemies, self.switches
end

function World_model:getTarget(sv, v)
    local obj = {}

    for _, w in pairs(self.walls) do
        local v1 = Vec2D.rotateByVec(w.p1 - sv, v)
        local v2 = Vec2D.rotateByVec(w.p2 - sv, v)
        if v1.x > 0 and v2.x > 0 and v1.y * v2.y < 0 then
            w.dist = Vec2D.getLength(sv - w.pos)
            table.insert(obj, w)
        end
    end

    for _, c in pairs(self.characters) do
        if c.alive == true then
            local dist = Vec2D.getLength(Vec2D.project(v, c.pos - sv))
            local offset = Vec2D.getLength(Vec2D.project(v, Vec2D.rotate(c.pos - sv, math.pi / 2)))
            if dist >= c.radius and offset <= c.radius then
                c.dist = Vec2D.getLength(sv - c.pos)
                table.insert(obj, c)
            end
        end
    end

    table.sort(obj, function(o1, o2) return o1.dist < o2.dist end)
    return obj[1]
end

function World_model.characterCollision(character, otherCharacter)
    local minDist = character.radius + otherCharacter.radius
    local diff = character.pos - otherCharacter.pos
    local dist = Vec2D.getLength(diff)

    local newPos = character.pos
    if dist < minDist then
        newPos = otherCharacter.pos + Vec2D.mul(Vec2D.normalize(diff), minDist)
    end

    return newPos
end

function World_model.wallCollision(character, wall)
    local faceDist = Vec2D.getLength(Vec2D.project(character.pos - wall.pos, wall.normal))
    local paraOffset = Vec2D.getLength(Vec2D.project(character.pos - wall.pos, wall.direction))

    local newPos = character.pos
    if math.abs(paraOffset) <= 0.5 then
        if math.abs(faceDist) < character.radius then
            local correction = Vec2D.mul(wall.normal, character.radius - faceDist)
            newPos = character.pos + correction
        end
    elseif paraOffset < -0.5 and faceDist > 0 then
        local cornerOffset = character.pos - wall.p1
        local dist = Vec2D.getLength(cornerOffset)
        if dist < character.radius then
            newPos = character.pos + Vec2D.mul(cornerOffset, character.radius - dist)
        end
    elseif paraOffset > 0.5 and faceDist > 0 then
        local cornerOffset = character.pos - wall.p2
        local dist = Vec2D.getLength(cornerOffset)
        if dist < character.radius then
            newPos = character.pos + Vec2D.mul(cornerOffset, character.radius - dist)
        end
    end

    return newPos
end

function World_model:getState()
    local levelComplete = false
    for _, switch in pairs(self.switches) do
        if (switch.type == "g" and switch.pushed == true) then
            levelComplete = true
        end
    end

    if self.player.alive == false then
        return "gameOver"
    elseif levelComplete == true then
        return "levelComplete"
    else
        return "running"
    end
end
