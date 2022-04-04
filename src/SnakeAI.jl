module SnakeAI

using GameZero

export play_snake

function play_snake()
    GameZero.rungame("extras/HumanPlayableSnake.jl")
end

include("utils/config.jl")
include("point.jl")
include("snake.jl")
include("game.jl")

end
