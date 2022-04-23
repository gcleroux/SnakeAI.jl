import ..SnakeAI

function train!(agent::AbstractAgent, game::SnakeAI.Game)
    # Get the current step
    old_state = SnakeAI.get_state(game)

    # Get the predicted move for the state
    move = get_action(agent, old_state)
    SnakeAI.send_inputs!(game, move)

    # Play the step
    reward, done, score = SnakeAI.play_step!(game)
    new_state = SnakeAI.get_state(game)

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
            agent.record = score
            # save_model(joinpath(MODELS_PATH, "model_$(agent.n_games).bson"), agent.model)
        end
    end

    return done
end

function remember(
    agent::AbstractAgent,
    state::S,
    action::S,
    reward::T,
    next_state::S,
    done::Bool
) where {T<:Integer,S<:AbstractArray{<:T}}
    push!(agent.memory.data, (state, action, [reward], next_state, convert.(Int, [done])))
end

function train_short_memory(
    agent::AbstractAgent,
    state::S,
    action::S,
    reward::T,
    next_state::S,
    done::Bool
) where {T<:Integer,S<:AbstractArray{<:T}}
    update!(agent, state, action, reward, next_state, convert(Int, done))
end

function train_long_memory(agent::AbstractAgent)
    if length(agent.memory.data) > BATCH_SIZE
        mini_sample = sample(agent.memory.data, BATCH_SIZE)
    else
        mini_sample = agent.memory.data
    end

    states, actions, rewards, next_states, dones = map(x -> getfield.(mini_sample, x), fieldnames(eltype(mini_sample)))

    update!(agent, states, actions, rewards, next_states, dones)
end

function get_action(agent::SnakeAgent, state::AbstractArray{<:Integer}; rand_range=1:200)
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

function update!(
    agent::SnakeAgent,
    state::Union{A,AA},
    action::Union{A,AA},
    reward::Union{T,AA},
    next_state::Union{A,AA},
    done::Union{T,AA};
    γ::Float32=0.9f0
) where {T<:Integer,A<:AbstractArray{<:T},AA<:AbstractArray{A}}

    # Batching the states and converting data to Float32 (done implicitly otherwise)
    state = Flux.batch(state) |> x -> convert.(Float32, x)
    next_state = Flux.batch(next_state) |> x -> convert.(Float32, x)
    action = Flux.batch(action)
    reward = Flux.batch(reward) |> x -> convert.(Float32, x)
    done = Flux.batch(done)

    # Current expected reward
    Q₀ = agent.model(state)

    # Expected values of next state
    Qₙ = agent.model(next_state)

    # Adjusting values of current state with next state's knowledge
    for idx in 1:length(done)

        Q′ = reward[idx]
        if done[idx] == 0
            Q′ = reward[idx] + γ * maximum(Qₙ[:, idx])
        end

        # Adjusting the expected reward for selected move
        Q₀[argmax(action[:, idx]), idx] = Q′
    end

    # Get the model's params for back propagation
    params = Flux.params(agent.model)

    # Calculate the gradient
    gradient = Flux.gradient(params) do
        ŷ = agent.model(state)
        agent.criterion(ŷ, Q₀)
    end

    # Update model weights
    Flux.Optimise.update!(agent.opt, params, gradient)
end
