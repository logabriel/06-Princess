--[[
    ISPPV1 2024
    Study Case: The Legend of the Princess (ARPG)

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by Alejandro Mujica (alejandro.j.mujic4@gmail.com) for teaching purpose.

    This file contains the class Dungeon.
]]
Dungeon = Class{}

function Dungeon:init(player)
    self.player = player
    -- current room we're operating in
    self.currentRoom = Room(self.player)

    -- room we're moving camera to during a shift; becomes active room afterwards
    self.nextRoom = nil

    -- love.graphics.translate values, only when shifting screens
    self.cameraX = 0
    self.cameraY = 0
    self.shifting = false

    -- trigger camera translation and adjustment of rooms whenever the player triggers a shift
    -- via a doorway collision, triggered in PlayerWalkState
    Event.on('shift-left', function()
        self:beginShifting(-VIRTUAL_WIDTH, 0)
    end)

    Event.on('shift-right', function()
        self:beginShifting(VIRTUAL_WIDTH, 0)
    end)

    Event.on('shift-up', function()
        self:beginShifting(0, -VIRTUAL_HEIGHT)
    end)

    Event.on('shift-down', function()
        self:beginShifting(0, VIRTUAL_HEIGHT)
    end)
end

--[[
    Prepares for the camera shifting process, kicking off a tween of the camera position.
]]
function Dungeon:beginShifting(shiftX, shiftY)
    self.shifting = true

    -- Determinar si se debe generar sala de jefe
    local isBossRoom = false
    if self.player.bow and math.random() < 0.5 then
        isBossRoom = true
    end

    -- Crear la siguiente sala, pasando el flag de jefe si corresponde
    self.nextRoom = Room(self.player, isBossRoom)

    -- start all doors in next room as open until we get in
    for _, doorway in pairs(self.nextRoom.doorways) do
        doorway.open = true
    end

    self.nextRoom.adjacentOffsetX = shiftX
    self.nextRoom.adjacentOffsetY = shiftY

    -- tween the player position so they move through the doorway
    local playerX, playerY = self.player.x, self.player.y

    if shiftX > 0 then
        playerX = VIRTUAL_WIDTH + (MAP_RENDER_OFFSET_X + TILE_SIZE)
    elseif shiftX < 0 then
        playerX = -VIRTUAL_WIDTH + (MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE - self.player.width)
    elseif shiftY > 0 then
        playerY = VIRTUAL_HEIGHT + (MAP_RENDER_OFFSET_Y + self.player.height / 2)
    else
        playerY = -VIRTUAL_HEIGHT + MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE - self.player.height
    end

    -- tween the camera in whichever direction the new room is in, as well as the player to be
    -- at the opposite door in the next room, walking through the wall (which is stenciled)

    local toTween = {
        [self] = {cameraX = shiftX, cameraY = shiftY},
        [self.player] = {x = playerX, y = playerY}
    }

    local pot = self.player.stateMachine.current.pot

    if pot ~= nil then
        toTween[pot] = {x = playerX, y = playerY - pot.height / 2}
    end
    
    Timer.tween(1, toTween):finish(function()
        local nextRoom = self.nextRoom
        self:finishShifting()

        -- reset player to the correct location in the room
        if shiftX < 0 then
            self.player.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE - self.player.width
            self.player.direction = 'left'
        elseif shiftX > 0 then
            self.player.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.player.direction = 'right'
        elseif shiftY < 0 then
            self.player.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE - self.player.height
            self.player.direction = 'up'
        else
            self.player.y = MAP_RENDER_OFFSET_Y + self.player.height / 2
            self.player.direction = 'down'
        end

        if isBossRoom and nextRoom and nextRoom.boss then
            self.player.x = MAP_RENDER_OFFSET_X + math.floor(MAP_WIDTH / 2) * TILE_SIZE
            self.player.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT - 2) * TILE_SIZE
            self.player.direction = 'up'

            local boss = nextRoom.boss
            boss.health = boss.maxHealth or 20
            boss.immune = true
            boss.immuneTimer = 0
            boss.dead = false
            boss.fireballs = {}
        end

        if self.currentRoom then
            for _, doorway in pairs(self.currentRoom.doorways) do
                doorway.open = false
            end
            self.currentRoom.adjacentOffsetX = 0
            self.currentRoom.adjacentOffsetY = 0
        else
        end

        -- Avoid to receive damage when entering to the new room
        self.player:goInvulnerable(1)

        SOUNDS['door']:play()
    end)
end

--[[
    Resets a few variables needed to perform a camera shift and swaps the next and
    current room.
]]
function Dungeon:finishShifting()
    self.cameraX = 0
    self.cameraY = 0
    self.shifting = false

    if self.nextRoom then
        self.currentRoom = self.nextRoom
        self.nextRoom = nil
    else
    end
end

function Dungeon:update(dt)
    -- pause updating if we're in the middle of shifting
    if not self.shifting then
        if self.currentRoom then
            self.currentRoom:update(dt)
        else
        end
    else
        -- still update the player animation if we're shifting rooms
        self.player.currentAnimation:update(dt)
    end
end

function Dungeon:render()
    -- translate the camera if we're actively shifting
    if self.shifting then
        love.graphics.translate(-math.floor(self.cameraX), -math.floor(self.cameraY))
    end

    if self.currentRoom then
        self.currentRoom:render()
    end
    
    if self.nextRoom then
        self.nextRoom:render()
    end
end
