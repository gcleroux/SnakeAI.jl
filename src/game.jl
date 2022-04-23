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

function get_state(game::Game)
    head = game.snake.head
    point_l = Point(head.x - BLOCK_SIZE, head.y)
    point_r = Point(head.x + BLOCK_SIZE, head.y)
    point_u = Point(head.x, head.y - BLOCK_SIZE)
    point_d = Point(head.x, head.y + BLOCK_SIZE)

    dir_l = game.direction == LEFT
    dir_r = game.direction == RIGHT
    dir_u = game.direction == UP
    dir_d = game.direction == DOWN

    # Create the state vector
    state = [
        # Danger straight
        (dir_r && is_collision(game.snake, point_r)) ||
        (dir_l && is_collision(game.snake, point_l)) ||
        (dir_u && is_collision(game.snake, point_u)) ||
        (dir_d && is_collision(game.snake, point_d)),

        # Danger right
        (dir_u && is_collision(game.snake, point_r)) ||
        (dir_d && is_collision(game.snake, point_l)) ||
        (dir_l && is_collision(game.snake, point_u)) ||
        (dir_r && is_collision(game.snake, point_d)),

        # Danger left
        (dir_d && is_collision(game.snake, point_r)) ||
        (dir_u && is_collision(game.snake, point_l)) ||
        (dir_r && is_collision(game.snake, point_u)) ||
        (dir_l && is_collision(game.snake, point_d)),

        # Move direction
        dir_l,
        dir_r,
        dir_u,
        dir_d,

        # Food location 
        game.food.x < game.snake.head.x,  # food left
        game.food.x > game.snake.head.x,  # food right
        game.food.y < game.snake.head.y,  # food up
        game.food.y > game.snake.head.y   # food down
    ]

    return convert.(Int, state)
end

function send_inputs!(game::Game, move::AbstractArray{<:Integer})
    if move == [1, 0, 0]
        new_dir = game.direction    # No changes in direction
    elseif move == [0, 1, 0]
        idx = Int(game.direction) + 1
        idx > 4 ? idx = 1 : nothing
        new_dir = Direction(idx)    # Turning clockwise
    elseif move == [0, 0, 1]
        idx = Int(game.direction) - 1
        idx < 1 ? idx = 4 : nothing
        new_dir = Direction(idx)    # Turning anticlockwise
    end

    # Perform the move
    game.direction = new_dir
    return
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
