require("world_model")
require("world_view")
require("player")

player = nil
worldModel = nil
mouseDelta = 0

function love.load()
	love.window.setTitle("Dungeon")

	if love.mouse.isGrabbed() == false then
		love.mouse.setGrabbed(true)
		love.mouse.setRelativeMode(true)
	end

	local worldWidth = 8
	local worldString = "########\z
						 # p    #\z
						 #      #\z
						 #    # #\z
						 #  ### #\z
						 #      #\z
						 ########"

	worldModel = World_model:new()
	player = worldModel:init(worldString, worldWidth)
end

function love.update(dt)
	if love.window.hasFocus() then
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

