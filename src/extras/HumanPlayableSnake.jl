using ..SnakeAI

const WIDTH = SnakeAI.WIDTH
const HEIGHT = SnakeAI.HEIGHT
const BACKGROUND = colorant"black"
const SPEED = 8

game = SnakeAI.Game()
step = 0

function draw()
    # Drawing the snake
    for p in game.snake.body
        r = Rect(p.x, p.y, SnakeAI.BLOCK_SIZE, SnakeAI.BLOCK_SIZE)
        draw(r, colorant"blue", fill=true)
    end

    # Drawing the food
    f = Rect(game.food.x, game.food.y, SnakeAI.BLOCK_SIZE, SnakeAI.BLOCK_SIZE)
    draw(f, colorant"red", fill=true)
end

function update(g::GameZero.Game)
    global step

    # Movement keys
    if g.keyboard.UP && game.snake.last_move != SnakeAI.DOWN
        game.direction = SnakeAI.UP
    elseif g.keyboard.DOWN && game.snake.last_move != SnakeAI.UP
        game.direction = SnakeAI.DOWN
    elseif g.keyboard.LEFT && game.snake.last_move != SnakeAI.RIGHT
        game.direction = SnakeAI.LEFT
    elseif g.keyboard.RIGHT && game.snake.last_move != SnakeAI.LEFT
        game.direction = SnakeAI.RIGHT
    end

    if step == SPEED
        step = 0
        play_step!(game)
    else
        step += 1
    end
end
