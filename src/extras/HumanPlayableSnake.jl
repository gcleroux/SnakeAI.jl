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
        outside = Rect(p.x, p.y, SnakeAI.BLOCK_SIZE, SnakeAI.BLOCK_SIZE)
        inside = Rect(p.x + 2, p.y + 2, SnakeAI.BLOCK_SIZE - 4, SnakeAI.BLOCK_SIZE - 4)
        draw(outside, colorant"#00262a", fill=true)
        draw(inside, colorant"#00717f", fill=true)

    end

    # Drawing the food
    f = Rect(game.food.x, game.food.y, SnakeAI.BLOCK_SIZE, SnakeAI.BLOCK_SIZE)
    draw(f, colorant"#7F0071", fill=true)
end

function update(g::GameZero.Game)
    global game, step

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
        _, game_over, score = play_step!(game)

        if game_over
            println(
                """
                ==================
                GAME OVER!
                Final Score: $(score)
                ==================\n""")
            # Reset the game
            reset!(game)
        end
    else
        step += 1
    end
end
