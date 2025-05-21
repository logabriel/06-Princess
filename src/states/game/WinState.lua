WinState = Class{__includes = BaseState}

function WinState:init()
end

function WinState:exit()
end

function WinState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        stateMachine:change('start')
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function WinState:render()
    love.graphics.setFont(FONTS['princess'])
    love.graphics.setColor(love.math.colorFromBytes(34, 139, 34, 255))
    love.graphics.printf('YOU WIN!', 0, VIRTUAL_HEIGHT / 2 - 48, VIRTUAL_WIDTH, 'center')
    
    love.graphics.setFont(FONTS['princess-small'])
    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 255))
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
end
