mutable struct Game
    snake::Snake
    food::Point
    direction::Direction
    score::Int

    function Game()
        snake = Snake()
        food = place_food(snake)

        new(snake, food, RIGHT, 0)
    end
end

function Base.show(io::IO, game::Game)
    println("Snake Game")
    println("==========")
    println("Snake -> ", game.snake)
    println("Food -> ", game.food)
    println("Direction -> ", game.direction)
    println("Score -> ", game.score)
end

function place_food(s::Snake)
    x = rand(0:(WIDTH-BLOCK_SIZE)÷BLOCK_SIZE) * BLOCK_SIZE
    y = rand(0:(HEIGHT-BLOCK_SIZE)÷BLOCK_SIZE) * BLOCK_SIZE

    # Create new food
    food = Point(x, y)

    # Look if food is inside the snake
    if food in s.body
        return place_food(s)
    end

    return food
end

function reset!(game::Game)
    snake = Snake()
    food = place_food(snake)

    game.snake = snake
    game.food = food
    game.direction = RIGHT
    game.score = 0
end

function play_step!(g::Game)
    # Move the snake position
    tail = move!(g.snake, g.direction)
    
    # Check if game is over
    reward = 0
    game_over = false
    # Look for collisions
    if is_collision(g.snake)
        game_over = true
        reward = -10
        
    elseif g.snake.head == g.food
        # Snake's length grows by one block
        push!(g.snake.body, tail)

        # Adjust the score and place new food
        g.score += 1
        reward = 10
        g.food = place_food(g.snake)
    end

    return reward, game_over, g.score
end