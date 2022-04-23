import DataStructures: CircularBuffer
import Flux
import ..SnakeAI
import StatsBase: sample

# Data type for agent's memory
const AgentMemoryData = NTuple{5,Vector{Int}}

# Constants for the agent
const MAX_MEMORY = 100_000
const BATCH_SIZE = 1000
const LR = 1e-3

Base.@kwdef mutable struct LinearAgent <: AbstractAgent
    n_games::Int = 0
    record::Int = 0
    ϵ::Int = 0 # Randomness
    memory::CircularBuffer = CircularBuffer{AgentMemoryData}(MAX_MEMORY)
    model::Flux.Chain = SnakeAI.linear_QNet(11, 256, 3)
    opt::Flux.ADAM = Flux.ADAM(LR)
    criterion::Function = Flux.mse
end

function remember(agent::LinearAgent, state::S, action::S, reward::T, next_state::S, done::Bool) where {T<:Int,S<:AbstractVector{T}}
    push!(agent.memory, (state, action, [reward], next_state, convert.(Int, [done])))
end

function train_short_memory(agent::LinearAgent, state::S, action::S, reward::T, next_state::S, done::Bool) where {T<:Int,S<:AbstractVector{T}}
    update!(agent, state, action, reward, next_state, convert(Int, done))
end

function train_long_memory(agent::LinearAgent)
    if length(agent.memory) > BATCH_SIZE
        mini_sample = sample(agent.memory, BATCH_SIZE)
    else
        mini_sample = agent.memory
    end

    states, actions, rewards, next_states, dones = map(x -> getfield.(mini_sample, x), fieldnames(eltype(mini_sample)))

    update!(agent, states, actions, rewards, next_states, dones)
end

function get_action(agent::LinearAgent, state::AbstractVector{Int}; rand_range=1:200)
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
    agent::LinearAgent,
    state,
    action,
    reward,
    next_state,
    done;
    γ::Float32=0.9f0)

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