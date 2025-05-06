ProjectileFactory = Class{}

function ProjectileFactory:init(type)
    self.proyectil = nil
    self.type = type
end

function ProjectileFactory:createProjectile(posX, posY, dir)
    self.proyectil = GameObject(GAME_OBJECT_DEFS[self.type], posX, posY)
    self.proyectil.state = self.type..'-'.. dir

    return self.proyectil
    
end