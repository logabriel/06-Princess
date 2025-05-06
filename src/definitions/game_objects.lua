--[[
    ISPPV1 2024
    Study Case: The Legend of the Princess (ARPG)

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by Alejandro Mujica (alejandro.j.mujic4@gmail.com) for teaching purpose.

    This file contains the definition for game objects.
]]
GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 16,
        width = 16,
        height = 16,
        solid = true,
        consumable = false,
        defaultState = 'default',
        takeable = true,
        states = {
            ['default'] = {
                frame = 16
            }
        }
    },
    -- definition of heart as a consumable object type
    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        consumable = true,
        defaultState = 'default',
        states = {
            ['default'] = {
                frame = 5
            }
        },
        onConsume = function(player)
            player:heal(2)
            SOUNDS['heart-taken']:play()
            --prueba de efectos de sonido
            --SOUNDS['arrow_impact']:play()
            --SOUNDS['open_chest']:play()
            --SOUNDS['ball_fire']:play()
        end
    },
    ['chest'] = {
        type = 'chest',
        texture = 'chest',
        frame = 2,
        width = 16,
        height = 16,
        solid = true,
        consumable = false,
        defaultState = 'closed-down',
        openable = true,
        states = {
            ['closed-down'] = {
                frame = 2
            },
            ['open-down'] = {
                frame = 1,
            },
            ['closed-up'] = {
                frame = 8,
            },
            ['open-up'] = {
                frame = 7,
            },
            ['closed-left'] = {
                frame = 4,
            },
            ['open-left'] = {
                frame = 3,
            },
            ['closed-right'] = {
                frame = 6,
            },
            ['open-right'] = {
                frame = 5,
            },
        },
        ['bow'] = {
            type = 'bow',
            texture = 'bow',
            width = 16,
            height = 16,
            solid = false,
            consumable = true,
            defaultState = 'default',
            state = {
                ['default'] = {
                    frame = 1
                }
            },
            onConsume = function(player)
                SOUNDS['arrow_impact']:play()
                player.bow = true
            end
        },
        ['arrow'] = {
            type = 'arrow',
            texture = 'arrow',
            frame = 1,
            width = 16,
            height = 16,
            solid = false,
            consumable = true,
            defaultState = 'arrow-left',
            takeable = true,
            states = {
                ['arrow-left'] = {
                    frame = 1
                },
                ['arrow-right'] = {
                    frame = 2
                },
                ['arrow-up'] = {
                    frame = 3
                },
                ['arrow-down'] = {
                    frame = 4
                }
            }
        }
    }
}
