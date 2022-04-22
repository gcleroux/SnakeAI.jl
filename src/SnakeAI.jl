module SnakeAI
"""
TODO: 
   - Have a types.jl file that includes Point, Snake, Game, Agent...
   - Adjust type hints in agent.jl
   - Convert state to float maybe, 
"""


import GameZero

export play_snake,
    train_agent,
    Game,
    play_step!,
    train_step!,
    reset!

function play_snake()
    GameZero.rungame("src/extras/HumanPlayableSnake.jl")
end

function train_agent()
    GameZero.rungame("src/extras/AgentPlayedSnake.jl")
end

include("constants.jl")
include("point.jl")
include("snake.jl")
include("game.jl")
include("model.jl")
include("agent.jl")

end
