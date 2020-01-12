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

require("player")
require("world_model")
require("world_view")

player = nil
worldModel = nil
mouseDelta = 0
levelIndex = 1
levels = {
    -- level 1
    {worldWidth = 9,
     worldString = "#########\z
                    ####p####\z
                    #### ####\z
                    #       #\z
                    #       #\z
                    #  ###  #\z
                    #   g   #\z
                    #       #\z
                    #       #\z
                    ## # # ##\z
                    ##s#s#s##\z
                    #########"},
    -- level 2
    {worldWidth = 15,
     worldString = "###############\z
                    #   #         #\z
                    # #  e####### #\z
                    #s# ###  s#   #\z
                    ###   # ### ###\z
                    #   #   #p#   #\z
                    # ### # # # # #\z
                    #  e#       # #\z
                    ### ## # #### #\z
                    #      # #g#e #\z
                    ### #### # ## #\z
                    #s       #    #\z
                    ###############"},
    -- level 3
    {worldWidth = 20,
     worldString = "####################\z
                    #p#                #\z
                    # # ####### ###### #\z
                    # # # #s    #  e   #\z
                    #   # #     #  #####\z
                    # ### ####     #   #\z
                    # #e     #      e# #\z
                    # ###### #   ##### #\z
                    #            #e  # #\z
                    # ########         #\z
                    # #se      ####### #\z
                    # #####    #   e   #\z
                    #          # #######\z
                    # ######## #       #\z
                    # #  e   # #   e # #\z
                    ######## # # ##### #\z
                    # g #      #s#     #\z
                    #   ###### ####### #\z
                    #    e            e#\z
                    ####################"}
}

function love.load()
    love.window.setTitle("Dungeon")
    if love.mouse.isGrabbed() == false then
        love.mouse.setGrabbed(true)
        love.mouse.setRelativeMode(true)
    end
    worldModel, player = World_model.new(levels[1])
end

function love.update(dt)
    if love.window.hasFocus() and worldModel:getState() == "running" then
        worldModel:update(dt, mouseDelta)
    end
    mouseDelta = 0
end

function love.draw()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local lastLevel = levelIndex == #levels
    World_view.draw(w, h, worldModel, lastLevel)
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
    if key == "space" then
        if worldModel:getState() == "levelComplete" then
            if levelIndex < #levels then
                local health = player.health
                levelIndex = levelIndex + 1
                worldModel, player = World_model.new(levels[levelIndex])
                player.health = health
            else
                levelIndex = 1
                worldModel, player = World_model.new(levels[levelIndex])
            end
        elseif worldModel:getState() == "gameOver" then
            levelIndex = 1
            worldModel, player = World_model.new(levels[levelIndex])
        end
    elseif key == "tab" then
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
