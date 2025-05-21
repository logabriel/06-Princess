--[[
    ISPPV1 2024
    Study Case: The Legend of the Princess (ARPG)

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by Alejandro Mujica (alejandro.j.mujic4@gmail.com) for teaching purpose.

    This file contains the class Player.
]]
Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.bow = false
    self.arrow = nil
    self.arrowLive = false
    self.arrowFactory = ProjectileFactory('arrow')

    Event.on('get_bow', function()
        self.bow = true
    end)
end

function Player:update(dt)
    Entity.update(self, dt)

    -- Detección de colisión con jefe y bolas de fuego (si está en sala de jefe)
    if self.room and self.room.isBossRoom and self.room.boss and not self.room.boss.dead then
        local boss = self.room.boss

        -- Colisión con el jefe (pierde un corazón completo)
        if not self.invulnerable and
            self.x < boss.x + boss.width and
            self.x + self.width > boss.x and
            self.y < boss.y + boss.height and
            self.y + self.height > boss.y then
            self:damage(2)
            self:goInvulnerable(1)
            if self.health <= 0 then
                stateMachine:change('game-over')
                return
            end
        end

        -- Colisión con bolas de fuego (muerte instantánea)
        for _, fb in ipairs(boss.fireballs) do
            if self.x < fb.x + fb.width and
                self.x + self.width > fb.x and
                self.y < fb.y + fb.height and
                self.y + self.height > fb.y then
                self.health = 0
                stateMachine:change('game-over')
                return
            end
        end
    end
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:render()
    Entity.render(self)
    
    if self.bow then
        love.graphics.draw(TEXTURES['bow'], FRAMES['bow'][1],
            VIRTUAL_WIDTH - TILE_SIZE * 2,
            2 )
    end
    -- love.graphics.setColor(love.math.colorFromBytes(255, 0, 255, 255))
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 255))
end

function Player:fire(dungeon)
    self.arrow = self.entity.arrowFactory:createProjectile(self.entity.x, self.entity.y, self.entity.direction)
    
    table.insert(dungeon.currentRoom.projectiles, Projectile(self.arrow, self.entity.direction))
    self.entity.arrowLive = true
    Timer.after(1.5, function ()
        self.entity.arrowLive = false
    end)
end
