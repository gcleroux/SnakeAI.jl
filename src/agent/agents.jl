import Flux
import ..SnakeAI
import StatsBase: sample

# Constants for the agent
const BATCH_SIZE = 1000
const LR = 1e-3

# AbstractAgent interface
abstract type AbstractAgent end

function get_action end
function update! end


Base.@kwdef mutable struct SnakeAgent <: AbstractAgent
    n_games::Int = 0
    record::Int = 0
    ϵ::Int = 0
    memory::AgentMemory = CircularBufferMemory()
    model::Flux.Chain = SnakeAI.linear_QNet(11, 256, 3)
    opt::Flux.Optimise.AbstractOptimiser = Flux.ADAM(LR)
    criterion::Function = Flux.Losses.mse
end

function Base.show(io::IO, agent::SnakeAgent)
    println("n_games => ", agent.n_games)
    println("record => ", agent.record)
    println("ϵ => ", agent.ϵ)
    println("memory => ", typeof(agent.memory.data))
    println("model => ", agent.model)
    println("optimizer => ", typeof(agent.opt))
    println("criterion => ", String(Symbol(agent.criterion)))
end
