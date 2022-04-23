using SnakeAI

const WIDTH = SnakeAI.WIDTH
const HEIGHT = SnakeAI.HEIGHT
const BACKGROUND = colorant"black"

game = SnakeAI.Game()
agent = SnakeAgent()

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
    global agent, game

    train!(agent, game)
end
