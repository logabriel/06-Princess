BossVampire = Class{}

local FRAME_WIDTH = 24
local FRAME_HEIGHT = 32
local FIREBALL_TEXTURE = love.graphics.newImage('assets/textures/fireball.png')
local FIREBALL_SOUND = love.audio.newSource('assets/sounds/hechizo_fuego.wav', 'static')

function BossVampire:init(x, y)
    self.x = x
    self.y = y
    self.width = FRAME_WIDTH
    self.height = FRAME_HEIGHT
    self.texture = love.graphics.newImage('assets/textures/vampire.png')
    self.frame = love.graphics.newQuad(
        FRAME_WIDTH,        
        FRAME_HEIGHT * 2,   
        FRAME_WIDTH,
        FRAME_HEIGHT,
        self.texture:getDimensions()
    )
    self.health = 20
    self.maxHealth = 20
    self.immune = true
    self.immuneTimer = 0
    self.dead = false
    self.fireballs = {}
    self.attackCooldown = 0
end

function BossVampire:update(dt, player)
    if self.dead then return end

    -- Actualizar inmunidad
    if not self.immune then
        self.immuneTimer = self.immuneTimer - dt
        if self.immuneTimer <= 0 then
            self.immune = true
        end
    end

    -- Ataque con bolas de fuego
    self.attackCooldown = self.attackCooldown - dt
    if self.attackCooldown <= 0 then
        self:shootFireball(player)
        self.attackCooldown = 3 + math.random() * 2
    end

    -- Actualizar bolas de fuego
    for i = #self.fireballs, 1, -1 do
        local fb = self.fireballs[i]
        fb.x = fb.x + fb.dx * dt
        fb.y = fb.y + fb.dy * dt

        -- Colisión con jugador (simplificada, ajusta según tu colisión)
        if fb.x + fb.width > player.x and fb.x < player.x + player.width and
           fb.y + fb.height > player.y and fb.y < player.y + player.height then
            player.dead = true
        end

        -- Eliminar bola de fuego si sale de pantalla
        if fb.x < 0 or fb.x > love.graphics.getWidth() or fb.y < 0 or fb.y > love.graphics.getHeight() then
            table.remove(self.fireballs, i)
        end
    end
end

function BossVampire:shootFireball(player)
    local px, py = player.x + player.width / 2, player.y + player.height / 2
    local bx, by = self.x + self.width / 2, self.y + self.height / 2
    local angle = math.atan2(py - by, px - bx)
    local speed = 60

    FIREBALL_SOUND:stop() 
    FIREBALL_SOUND:play()

    table.insert(self.fireballs, {
        x = bx,
        y = by,
        dx = speed * math.cos(angle),
        dy = speed * math.sin(angle),
        width = FIREBALL_TEXTURE:getWidth(),
        height = FIREBALL_TEXTURE:getHeight(),
        texture = FIREBALL_TEXTURE
    })
end

function BossVampire:render(offsetX, offsetY)
    love.graphics.draw(self.texture, self.frame, self.x + (offsetX or 0), self.y + (offsetY or 0))
    for _, fb in ipairs(self.fireballs) do
        love.graphics.draw(fb.texture, fb.x + (offsetX or 0), fb.y + (offsetY or 0))
    end
end

function BossVampire:hitByArrow()
    self.immune = false
    self.immuneTimer = 5
end

function BossVampire:hitBySword()
    if not self.immune then
        self.health = self.health - 1
        if self.health <= 0 then
            self.dead = true
        end
    end
end
