mutable struct Game
    snake::Snake
    food::Point
    direction::Direction
    score::Int64

    function Game()
        snake = Snake()
        food = place_food(snake)

        new(snake, food, RIGHT, 0)
    end
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

function play_step(g::Game)

    # Move the snake position
    tail = move(g.snake, g.direction)
    
    # Look for collisions
    if collide(g.snake)
        println(
            """
            ==================
            GAME OVER!
            Final Score: $(g.score)
            ==================\n""")
        # Reset the game
        return Game()
    end

    if g.snake.head == g.food
        # Snake's length grows by one block
        push!(g.snake.body, tail)

        # Adjust the score and place new food
        g.score += 1
        g.food = place_food(g.snake)
    end

    return g
end