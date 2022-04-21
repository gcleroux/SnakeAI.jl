import DataStructures: CircularBuffer
import Flux
import StatsBase: sample

# Type Definitions
const AgentMemoryData = NTuple{5,Vector{Int}}

Base.@kwdef mutable struct Agent
    n_games::Int = 0
    record::Int = 0
    ϵ::Int = 0 # Randomness
    γ::Float32 = 0.9  # Discount rate
    memory::CircularBuffer = CircularBuffer{AgentMemoryData}(MAX_MEMORY)
    model::Flux.Chain = create_linear_QNet(11, 256, 3)
    params = Flux.params(model)
    opt = Flux.ADAM(LR)
    criterion = Flux.mse
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

function remember(agent::Agent, state::S, action::S, reward::T, next_state::S, done::Bool) where {T<:Int,S<:AbstractVector{T}}
    push!(agent.memory, (state, action, [reward], next_state, convert.(Int, [done])))
end

function train_short_memory(agent::Agent, state::S, action::S, reward::T, next_state::S, done::Bool) where {T<:Int,S<:AbstractVector{T}}
    step!(agent, state, action, reward, next_state, convert(Int, done))
end

function train_long_memory(agent::Agent)
    if length(agent.memory) > BATCH_SIZE
        mini_sample = sample(agent.memory, BATCH_SIZE)
    else
        mini_sample = agent.memory
    end

    states, actions, rewards, next_states, dones = map(x -> getfield.(mini_sample, x), fieldnames(eltype(mini_sample)))

    step!(agent, states, actions, rewards, next_states, dones)
end

function get_action(agent::Agent, state::AbstractVector{Int}; rand_range=1:200)
    agent.ϵ = 80 - agent.n_games
    final_move = zeros(Int, 3)

    if rand(rand_range) < agent.ϵ
        move = rand(1:3)
        final_move[move] = 1
    else
        pred = agent.model(state)
        final_move[Flux.onecold(pred)] = 1
    end

    return final_move
end

function train(agent::Agent, game::Game)

    old_state = get_state(game)

    # Get the move
    final_move = get_action(agent, old_state)
    send_inputs!(game, final_move)

    reward, done, score = play_step!(game)
    new_state = get_state(game)

    # Train the short memory
    train_short_memory(agent, old_state, final_move, reward, new_state, done)

    # Remember
    remember(agent, old_state, final_move, reward, new_state, done)

    if done
        # Reset the game
        train_long_memory(agent)
        println("Game => $(agent.n_games)")
        println("Score => $(score)")
        reset!(game)
        agent.n_games += 1
        
        if score > agent.record
            agent.record = score
            # save_model(joinpath(MODELS_PATH, "model_$(agent.n_games).bson"), agent.model)
        end
    end

    return old_state, new_state
end

function send_inputs!(game::Game, inputs::AbstractVector{Int})
    if inputs == [1, 0, 0]
        new_dir = game.direction    # No changes in direction
    elseif inputs == [0, 1, 0]
        idx = Int(game.direction) + 1
        idx > 4 ? idx = 1 : nothing
        new_dir = Direction(idx)    # Turning clockwise
    elseif inputs == [0, 0, 1]
        idx = Int(game.direction) - 1
        idx < 1 ? idx = 4 : nothing
        new_dir = Direction(idx)    # Turning anticlockwise
    end

    # Perform the move
    game.direction = new_dir
end

function step!(agent, state, action, reward, next_state, done)

    # Batching the states
    state = Flux.batch(state)
    next_state = Flux.batch(next_state)
    action = Flux.batch(action)
    reward = Flux.batch(reward)
    done = Flux.batch(done)

    # Converting the data to float for training
    state = convert.(Float32, state)
    next_state = convert.(Float32, next_state)
    reward = convert.(Float32, reward)

    # Forward pass
    targets = agent.model(state)

    Q_news = agent.model(next_state)

    for idx in 1:length(done)

        Q_new = reward[idx]
        if done[idx] == 0
            Q_new = reward[idx] + agent.γ * maximum(Q_news[:, idx])
        end

        targets[argmax(action[:, idx]), idx] = Q_new

    end

    gradient = Flux.gradient(agent.params) do
        preds = agent.model(state)
        Flux.mse(preds, targets)
    end

    Flux.Optimise.update!(agent.opt, agent.params, gradient)
end