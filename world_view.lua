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
require("vec2D")
require("wall")

World_view = {}
World_view.fov = 1.5
World_view.images = {
    sky = love.graphics.newImage("images/sky.png"),
    ground = love.graphics.newImage("images/ground.png"),
    bullet = love.graphics.newImage("images/bullet.png")
}
endscreen = {
    gameOver = love.graphics.newImage("images/gameover.png"),
    levelComplete = love.graphics.newImage("images/levelcomplete.png"),
    theEnd = love.graphics.newImage("images/theend.png")
}

function World_view.draw(w, h, worldModel, lastLevel)
    -- draw sky and ground
    local xScaling = w / (World_view.images.sky:getWidth() * World_view.fov / (math.pi * 2))
    local drawWidth = World_view.images.sky:getWidth() * xScaling
    local skyOffset = (player.a / (math.pi * 2)) * drawWidth
    love.graphics.draw(World_view.images.sky, -skyOffset, 0, 0, xScaling)
    love.graphics.draw(World_view.images.sky, -skyOffset + drawWidth, 0, 0, xScaling)
    
    local xFactor = w / World_view.images.ground:getWidth()
    local yFactor = (h / 2) / World_view.images.ground:getHeight()
    love.graphics.draw(World_view.images.ground, 0, h / 2, 0, xFactor, yFactor)

    local player, walls, enemies, switches = worldModel:getObjects()
    local objects, switches = World_view.getObjectsInFOV(player, walls, enemies, switches)

    -- draw switches
    for _, switch in pairs(switches) do
        local x1, y1 = World_view.project(player, switch.pos, w, h)
        local x2, y2 = World_view.project(player, switch.pos + Vec2D.new(1, 0), w, h)
        local x3, y3 = World_view.project(player, switch.pos + Vec2D.new(1, 1), w, h)
        local x4, y4 = World_view.project(player, switch.pos + Vec2D.new(0, 1), w, h)
        love.graphics.setColor(World_view.adjustColorForDist(switch.color, switch.dist))
        love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3, x4, y4)
    end

    -- draw walls and enemies
    for _, o in pairs(objects) do
        if o.type == "w" then
            local x1, y1 = World_view.project(player, o.p1, w, h)
            local y2 = y1 - (y1 - (h / 2)) * 1.4
            local x3, y3 = World_view.project(player, o.p2, w, h)
            local y4 = y3 - (y3 - (h / 2)) * 1.4
            love.graphics.setColor(World_view.adjustColorForDist(o.color, o.dist))
            love.graphics.polygon('fill', x1, y1, x1, y2, x3, y4, x3, y3)
        end
        if o.type == "e" then
            local x, y = World_view.project(player, o.pos, w, h)
            local imageWidth = o.sprite:getWidth()
            local imageHeight = o.sprite:getHeight()
            local drawHeight = (y - (h / 2)) * 1.5
            local scaleFactor = drawHeight / imageHeight
            local drawWidth = imageWidth * scaleFactor
            love.graphics.setColor(World_view.adjustColorForDist({r = 1, g = 1, b = 1}, o.dist))
            love.graphics.draw(o.sprite, x - drawWidth / 2, y - drawHeight, 0, scaleFactor)
        end
    end

    -- draw crosshair
    love.graphics.setColor(255, 255, 255)
    love.graphics.line(w / 2, h / 2 - 30, w / 2, h / 2 + 30)
    love.graphics.line(w / 2 - 30, h / 2, w / 2 + 30, h / 2)

    -- draw energy meter
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 40, h - 62, 204, 14)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', 42, h - 60, player.health * 2, 10)

    -- draw bullets
    love.graphics.setColor(1, 1, 1)
    local bulletX = w - 40 - 25
    for i = 1, player.bullets do
        love.graphics.draw(World_view.images.bullet, bulletX, h - 90, 0, 0.5)
        bulletX = bulletX - 30
    end

    -- draw debug info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

    -- draw overlay
    if worldModel:getState() == "gameOver" then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle('fill', 0, 0, w, h)
        love.graphics.setColor(0, 0, 0)
        local imagePosX = (w / 2) - (endscreen.gameOver:getWidth() / 2)
        local imagePosY = (h / 2) - (endscreen.gameOver:getHeight() / 2)
        love.graphics.draw(endscreen.gameOver, imagePosX, imagePosY)
    elseif worldModel:getState() == "levelComplete" then
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle('fill', 0, 0, w, h)
        love.graphics.setColor(0, 0, 0)
        if lastLevel == true then
            local imagePosX = (w / 2) - (endscreen.theEnd:getWidth() / 2)
            local imagePosY = (h / 2) - (endscreen.theEnd:getHeight() / 2)
            love.graphics.draw(endscreen.theEnd, imagePosX, imagePosY)
        else
            local imagePosX = (w / 2) - (endscreen.levelComplete:getWidth() / 2)
            local imagePosY = (h / 2) - (endscreen.levelComplete:getHeight() / 2)
            love.graphics.draw(endscreen.levelComplete, imagePosX, imagePosY)
        end
    end
end

function World_view.getObjectsInFOV(player, walls, enemies, switches)
    local objects = {}
    for _, wall in pairs(walls) do
        if World_view.pointInFOV(player, wall.p1) or
           World_view.pointInFOV(player, wall.center) or
           World_view.pointInFOV(player, wall.p2) then
            wall.dist = Vec2D.getDistance(player.pos, wall.center)
            table.insert(objects, wall)
        end
    end

    for _, enemy in pairs(enemies) do
        local poDir = enemy.pos - player.pos
        local v1 = Vec2D.rotate(Vec2D.new(1, 0), player.a + World_view.fov / 2)
        local v2 = Vec2D.rotate(Vec2D.new(1, 0), player.a - World_view.fov / 2)
        local infov = Vec2D.sideOf(poDir, v1) > 0 and Vec2D.sideOf(poDir, v2) < 0
        v1 = Vec2D.rotateByVec(poDir, v1)
        v2 = Vec2D.rotateByVec(poDir, v2)
        if infov == true or
           (v1.x > 0.1 and math.abs(v1.y) < enemy.radius) or
           (v2.x > 0.1 and math.abs(v2.y) < enemy.radius) then
            enemy.dist = Vec2D.getDistance(player.pos, enemy.pos)
            table.insert(objects, enemy)
        end
    end

    local sw = {}
    for _, switch in pairs(switches) do
        if World_view.pointInFOV(player, switch.pos) or
           World_view.pointInFOV(player, switch.pos + Vec2D.new(1, 0)) or
           World_view.pointInFOV(player, switch.pos + Vec2D.new(0, 1)) or
           World_view.pointInFOV(player, switch.pos + Vec2D.new(1, 1)) then
            switch.dist = Vec2D.getDistance(player.pos, switch.pos + Vec2D.new(0.5, 0.5))
            table.insert(sw, switch)
        end
    end

    table.sort(objects, function(o1, o2) return o1.dist > o2.dist end)
    return objects, sw
end

function World_view.pointInFOV(player, point)
    local poDir = point - player.pos
    local v1 = Vec2D.rotate(Vec2D.new(1, 0), player.a + World_view.fov / 2)
    local v2 = Vec2D.rotate(Vec2D.new(1, 0), player.a - World_view.fov / 2)
    return Vec2D.sideOf(poDir, v1) > 0 and Vec2D.sideOf(poDir, v2) < 0
end

function World_view.project(player, point, w, h)
    local plDir = Vec2D.new(math.cos(player.a), math.sin(player.a))
    local poDir = Vec2D.normalize(point - player.pos)
    local d = 1
    if Vec2D.sideOf(plDir, poDir) < 0 then
        d = -1
    end

    local angleH = math.acos(Vec2D.dotProduct(plDir, poDir))
    local angleV = math.atan(1 / Vec2D.getDistance(player.pos, point))

    local pixelsPerDeg = w / World_view.fov
    local pixelsX = (w / 2) + pixelsPerDeg * angleH * d
    local pixelsY = (h / 2) + pixelsPerDeg * angleV
    return pixelsX, pixelsY
end

function World_view.adjustColorForDist(color, dist)
    local f = 0
    if dist <= 20 then
        f = (20 - dist) / 20
    end
    return color.r * f, color.g * f, color.b * f
end

