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

require("enemy")
require("player")
require("switch")
require("wall")
require("vec2D")

World_model = {}
World_model.player = nil
World_model.walls = {}
World_model.enemies = {}
World_model.switches = {}
World_model.__index = World_model

function World_model.new()
    local w = {}
    setmetatable(w, World_model)
    return w
end

function World_model:init(level)
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
                self.walls[wallID] = createWall(Vec2D.new(x + 1, y), "w")
            elseif c1 == "#" and c2 ~= "#" then
                local wallID = (x * 2^16) + (y * 2^8) + 1
                self.walls[wallID] = createWall(Vec2D.new(x + 1, y), "e")
            end
            if c1 ~= "#" and c3 == "#" then
                local wallID = (x * 2^16) + (y * 2^8) + 2
                self.walls[wallID] = createWall(Vec2D.new(x, y + 1), "n")
            elseif c1 == "#" and c3 ~= "#" then
                local wallID = (x * 2^16) + (y * 2^8) + 3
                self.walls[wallID] = createWall(Vec2D.new(x, y + 1), "s")
            end
        end
    end

    -- find player, enemies and switches
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local i = x + y * w
            local c = string.sub(worldString, i + 1, i + 1)

            if c == "p" then
                self.player = Player:new(Vec2D.new(x + 0.5, y + 0.5), self)
            elseif c == "e" then
                table.insert(self.enemies, Enemy:new(Vec2D.new(x + 0.5, y + 0.5), self))
            elseif c == "s" then
                local switch = Switch:new(Vec2D.new(x, y))
                switch.type = "s"
                switch.active = true
                table.insert(self.switches, switch)
            elseif c == "g" then
                local switch = Switch:new(Vec2D.new(x, y))
                switch.type = "g"
                switch.original_color = {r = 0, g = 0, b = 0.5}
                table.insert(self.switches, switch)
            end
        end
    end

    return self.player
end

function World_model:update(dt, mouseDelta)
    self.player:update(dt, mouseDelta)
    local px = math.floor(self.player.pos.x)
    local py = math.floor(self.player.pos.y)
    for wx = px - 1, px + 1 do
        for wy = py - 1, py + 1 do
            for wf = 0, 3 do
                wallID = (wx * 2^16) + (wy * 2^8) + wf
                if self.walls[wallID] ~= nil then
                    self.player.pos.x, self.player.pos.y = World_model.wallCollision(self.player, self.walls[wallID])
                end
            end
        end
    end

    for _, enemy in pairs(self.enemies) do
        enemy:update(dt)
    end

    local goalActive = true
    for _, switch in pairs(self.switches) do
        switch:update(dt, self.player)
        if switch.type == "s" and switch.pushed == false then
            goalActive = false
        end
    end
    if goalActive == true then
        for _, switch in pairs(self.switches) do
            if switch.type == "g" then
                switch.active = true
            end
        end
    end
end

function World_model:getObjects()
    return self.player, self.walls, self.enemies, self.switches
end

function World_model:getTarget(sv, v)
    local obj = {}

    local v1 = Vec2D.rotateByVec(player.pos - sv, v)
    if v1.x > 0.1 and math.abs(v1.y) < player.radius then
        player.dist = Vec2D.getDistance(sv, player.pos)
        table.insert(obj, player)
    end

    for _, wall in pairs(self.walls) do
        local v1 = Vec2D.rotateByVec(wall.p1 - sv, v)
        local v2 = Vec2D.rotateByVec(wall.p2 - sv, v)
        if v1.x > 0 and v2.x > 0 and v1.y * v2.y < 0 then
            wall.dist = Vec2D.getDistance(sv, wall.center)
            table.insert(obj, wall)
        end
    end

    for _, enemy in pairs(self.enemies) do
        if enemy.alive == true then
            local v1 = Vec2D.rotateByVec(enemy.pos - sv, v)
            if v1.x > 0.1 and math.abs(v1.y) < enemy.radius then
                enemy.dist = Vec2D.getDistance(sv, enemy.pos)
                table.insert(obj, enemy)
            end
        end
    end

    table.sort(obj, function(o1, o2) return o1.dist < o2.dist end)
    return obj[1]
end

function World_model.wallCollision(character, wall)
    local wallFaceDist = 0
    local parallelOffset = 0
    if wall.face == "n" then
        wallFaceDist = wall.center.y - character.pos.y
        parallelOffset = wall.center.x - character.pos.x
    elseif wall.face == "s" then
        wallFaceDist = character.pos.y - wall.center.y
        parallelOffset = character.pos.x - wall.center.x
    elseif wall.face == "w" then
        wallFaceDist = wall.center.x - character.pos.x
        parallelOffset = character.pos.y - wall.center.y
    elseif wall.face == "e" then
        wallFaceDist = character.pos.x - wall.center.x
        parallelOffset = wall.center.y - character.pos.y
    end

    local xCorr, yCorr = 0, 0
    if math.abs(parallelOffset) <= 0.5 then
        if math.abs(wallFaceDist) < character.radius then
            yCorr = character.radius - wallFaceDist
        end
    elseif parallelOffset < -0.5 and wallFaceDist >= 0 then
        local dx, dy = parallelOffset + 0.5, wallFaceDist
        local dist = math.sqrt(dx^2 + dy^2)
        if dist < character.radius then
            local f = character.radius / dist
            xCorr = (dx * f) - dx
            yCorr = (dy * f) - dy
        end
    elseif parallelOffset > 0.5 then
        local dx, dy = parallelOffset - 0.5, wallFaceDist
        local dist = math.sqrt(dx^2 + dy^2)
        if dist < character.radius then
            local f = character.radius / dist
            xCorr = (dx * f) - dx
            yCorr = (dy * f) - dy
        end
    end

    local pxn, pyn = character.pos.x, character.pos.y
    if wall.face == "n" then
        pxn = pxn - xCorr
        pyn = pyn - yCorr
    elseif wall.face == "s" then
        pxn = pxn + xCorr
        pyn = pyn + yCorr
    elseif wall.face == "w" then
        pxn = pxn - yCorr
        pyn = pyn - xCorr
    elseif wall.face == "e" then
        pxn = pxn + yCorr
        pyn = pyn + xCorr
    end

    return pxn, pyn
end

function World_model:levelFinished()
    local levelFinished = false
    for _, switch in pairs(self.switches) do
        if (switch.type == "g" and switch.pushed == true) then
            levelFinished = true
        end
    end
    return levelFinished
end
