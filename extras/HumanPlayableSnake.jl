using SnakeAI

const BACKGROUND = colorant"black"
const SPEED = 8

game = SnakeAI.Game()
step = 0

function draw()
    global game

    # Drawing the snake
    for p in game.snake.body
        r = Rect(p.x, p.y, BLOCK_SIZE, BLOCK_SIZE)
        draw(r, colorant"blue", fill=true)
    end

    # Drawing the food
    f = Rect(game.food.x, game.food.y, BLOCK_SIZE, BLOCK_SIZE)
    draw(f, colorant"red", fill=true)
end

function update(g::GameZero.Game)
    global game, step

    # Movement keys
    if g.keyboard.UP && game.snake.last_move != DOWN
        game.direction = UP
    elseif g.keyboard.DOWN && game.snake.last_move != UP
        game.direction = DOWN
    elseif g.keyboard.LEFT && game.snake.last_move != RIGHT
        game.direction = LEFT
    elseif g.keyboard.RIGHT && game.snake.last_move != LEFT
        game.direction = RIGHT
    end

    if step == SPEED
        step = 0
        game = play_step(game)
    else
        step += 1
    end
end
