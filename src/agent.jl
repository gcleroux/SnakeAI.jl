import DataStructures: CircularBuffer
import Flux: onecold
import StatsBase: sample

mutable struct Agent{T <: Integer}
    n_games::T
    ϵ::T  # Randomness
    γ::T  # Discount rate
    memory::CircularBuffer{T}
    model
    trainer
    # TODO: model, trainer

    function Agent()
        new{Int}(0, 0, 0, CircularBuffer{Int}(MAX_MEMORY), nothing, nothing)
    end
end

function get_state(game)
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

function remember(agent, state, action, reward, next_state, done)
    push!(agent.ϵ, (state, action, reward, next_state, done))
end

function train_short_memory(agent, state, action, reward, next_state, done)
    train_step!(agent.trainer, state, action, reward, next_state, done)
end

function train_long_memory(agent)
    if length(agent.ϵ) > BATCH_SIZE
        mini_sample = sample(agent.ϵ, BATCH_SIZE)
    else
        mini_sample = agent.ϵ
    end

    states, actions, rewards, next_states, dones = map(x->getfield.(mini_sample, x), fieldnames(eltype(mini_sample)))
    train_step(agent.trainer, states, actions, rewards, next_states, dones)
end

function get_action(agent::Agent, state; rand_range::UnitRange{Integer}=1:200)
    agent.ϵ = 80 - agent.n_games
    final_move = zeros(Int, 3)
    
    if rand(rand_range) < agent.ϵ
        move = rand(1:3)
        final_move[move] = 1
    else
        pred = agent.model(state)
        final_move[onecold(pred)] = 1
    end
end

function train()
    plot_scores = Int[]
    plot_mean_scores = []
    total_score = 0
    record = 0
    agent = Agent()
    game = SnakeAI.Game()

    while true
        old_state = get_state(game)

        # Get the move
        final_move = get_action(agent, old_state)

        # Perform the move
        game.direction = final_move
        reward, done, score = play_step!(game)
        new_state = get_state(game)

        # Train the short memory
        train_short_memory(agent, old_state, final_move, reward, new_state, done)

        # Remember
        remember(agent, old_state, final_move, reward, new_state, done)

        if done
            # Reset the game
            reset!(game)
            agent.n_games += 1
            train_long_memory(agent)

            if score > agent.record
                agent.record = score
                # TODO: save the model
            end
        end

        # TODO: Plotting the results

    end

end

