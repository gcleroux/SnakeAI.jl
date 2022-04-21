import ..SnakeAI
import ..SnakeAI: play_step!, reset!

const WIDTH = SnakeAI.WIDTH
const HEIGHT = SnakeAI.HEIGHT
const BACKGROUND = colorant"black"

game = SnakeAI.Game()
agent = SnakeAI.Agent()
plot_scores = Int[]
plot_mean_scores = []
total_score = 0
record = 0

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
    global agent, game, step
    
    SnakeAI.train(agent, game)
end
