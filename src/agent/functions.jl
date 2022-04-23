import ..SnakeAI
import ..SnakeAI: BLOCK_SIZE, Direction, LEFT, RIGHT, UP, DOWN


function get_state(game::Game)
    head = game.snake.head
    point_l = SnakeAI.Point(head.x - BLOCK_SIZE, head.y)
    point_r = SnakeAI.Point(head.x + BLOCK_SIZE, head.y)
    point_u = SnakeAI.Point(head.x, head.y - BLOCK_SIZE)
    point_d = SnakeAI.Point(head.x, head.y + BLOCK_SIZE)

    dir_l = game.direction == LEFT
    dir_r = game.direction == RIGHT
    dir_u = game.direction == UP
    dir_d = game.direction == DOWN

    # Create the state vector
    state = [
        # Danger straight
        (dir_r && SnakeAI.is_collision(game.snake, point_r)) ||
        (dir_l && SnakeAI.is_collision(game.snake, point_l)) ||
        (dir_u && SnakeAI.is_collision(game.snake, point_u)) ||
        (dir_d && SnakeAI.is_collision(game.snake, point_d)),

        # Danger right
        (dir_u && SnakeAI.is_collision(game.snake, point_r)) ||
        (dir_d && SnakeAI.is_collision(game.snake, point_l)) ||
        (dir_l && SnakeAI.is_collision(game.snake, point_u)) ||
        (dir_r && SnakeAI.is_collision(game.snake, point_d)),

        # Danger left
        (dir_d && SnakeAI.is_collision(game.snake, point_r)) ||
        (dir_u && SnakeAI.is_collision(game.snake, point_l)) ||
        (dir_r && SnakeAI.is_collision(game.snake, point_u)) ||
        (dir_l && SnakeAI.is_collision(game.snake, point_d)),

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
end

function train!(agent::AbstractAgent, game::Game)
    # Get the current step
    old_state = get_state(game)

    # Get the predicted move for the state
    move = get_action(agent, old_state)
    send_inputs!(game, move)

    # Play the step
    reward, done, score = SnakeAI.play_step!(game)
    new_state = get_state(game)

    # Train the short memory
    train_short_memory(agent, old_state, move, reward, new_state, done)

    # Remember
    remember(agent, old_state, move, reward, new_state, done)

    if done
        # Reset the game
        train_long_memory(agent)
        SnakeAI.reset!(game)
        agent.n_games += 1
    
        if score > agent.record
            @info "New record set!\n=> Score: $(score), Game #$(agent.n_games - 1)"
            agent.record = score
            # save_model(joinpath(MODELS_PATH, "model_$(agent.n_games).bson"), agent.model)
        end

        # Plotting the agents progress
    end
end