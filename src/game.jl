export Game,
    place_food,
    new_game,
    play_step

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

    # Calculate where to move the head
    head = move(g.snake, g.direction)
    g.snake.head = head
    pushfirst!(g.snake.body, head)

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

    # Place new food or move the snake
    if g.snake.head == g.food
        g.score += 1
        g.food = place_food(g.snake)
    else
        pop!(g.snake.body)
    end

    return g
end