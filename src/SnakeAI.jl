module SnakeAI
#=
TODO: 
- Plotting in real time of training's progress
- Modifying the state's vector to include information about the snake's body
- Adding tests on memory types
=#

export play_snake,
    demo_agent,
    train_agent,
    Game,
    play_step!,
    reset!

include("constants.jl")
include("point.jl")
include("snake.jl")
include("game.jl")

# Model module
include("model/Model.jl")
using .Model
export save_model

# Agent module
include("agent/Agent.jl")
using .Agent
export SnakeAgent,
    CircularBufferMemory,
    train!

include("functions.jl")

end
