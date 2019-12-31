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

require("player")
require("world_model")
require("world_view")

player = nil
worldModel = nil
mouseDelta = 0
levelIndex = 1
levels = {
	{worldString = "#########\z
					# p     #\z
					#      s#\z
					#       #\z
					#  ###  #\z
					#   g   #\z
					#e      #\z
					#########",
	 worldWidth = 9},
	{worldString = "################\z
					# p        s   #\z
					#              #\z
					#    #     e   #\z
					#  ###         #\z
					#    s     s   #\z
					#              #\z
					################",
	 worldWidth = 16}
}

function love.load()
	love.window.setTitle("Dungeon")

	if love.mouse.isGrabbed() == false then
		love.mouse.setGrabbed(true)
		love.mouse.setRelativeMode(true)
	end

	worldModel = World_model:new()
	player = worldModel:init(levels[1])
end

function love.update(dt)
	if love.window.hasFocus() then
		if (worldModel:levelFinished() == true) then
			if (levelIndex == #levels) then
				--os.exit()
			end
			levelIndex = levelIndex + 1
			print(levelIndex)
			worldModel = World_model.new()
			player = worldModel:init(levels[levelIndex])
		end
		worldModel:update(dt, mouseDelta)
	end
	mouseDelta = 0
end

function love.draw()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	World_view.draw(w, h, player, worldModel)
end

function love.mousemoved(x, y, dx, dy)
	mouseDelta = mouseDelta + dx
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		player:fire()
	elseif button == 2 then
		player:reload()
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "tab" then
		local state = not love.mouse.isGrabbed()
		love.mouse.setGrabbed(state)
		love.mouse.setRelativeMode(state)
	elseif key == "f" then
		local _, _, flags = love.window.getMode()
		if flags.fullscreen == false then
			local desktop_w, desktop_h = love.window.getDesktopDimensions()
			love.window.setMode(desktop_w, desktop_h, {fullscreen = true})
		else
			love.window.setMode(800, 600, {fullscreen = false})
		end
	elseif key == "escape" then
		os.exit()
	end
end
