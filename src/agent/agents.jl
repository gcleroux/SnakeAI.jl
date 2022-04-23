import DataStructures: CircularBuffer
import Flux
import ..SnakeAI
import StatsBase: sample

# Constants for the agent
const AgentMemoryData = NTuple{5,Vector{Int}}
const MAX_MEMORY = 100_000
const BATCH_SIZE = 1000
const LR = 1e-3

# AbstractAgent interface
abstract type AbstractAgent end

function get_action end
function remember! end
function train_short_memory! end
function train_long_memory! end
function update! end

Base.@kwdef mutable struct SnakeAgent{T<:Integer} <: AbstractAgent
    n_games::T = 0
    record::T = 0
    ϵ::T = 0
    memory::Any = CircularBuffer{AgentMemoryData}(MAX_MEMORY)
    model::Flux.Chain = SnakeAI.linear_QNet(11, 256, 3)
    opt::Flux.Optimise.AbstractOptimiser = Flux.ADAM(LR)
    criterion::Function = Flux.Losses.mse
end

function Base.show(io::IO, agent::SnakeAgent)
    println("n_games => ", agent.n_games)
    println("record => ", agent.record)
    println("ϵ => ", agent.ϵ)
    println("memory => ", typeof(agent.memory))
    println("model => ", agent.model)
    println("optimizer => ", typeof(agent.opt))
    println("criterion => ", String(Symbol(agent.criterion)))
end
