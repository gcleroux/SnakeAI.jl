module SnakeAI

import GameZero

export play_snake, 
    Game, 
    play_step!,
    reset!

function play_snake()
    GameZero.rungame("src/extras/HumanPlayableSnake.jl")
end

# TODO: Have a types.jl file that includes Point, Snake, Game, Agent...
include("constants.jl")
include("point.jl")
include("snake.jl")
include("game.jl")
include("agent.jl")

end
