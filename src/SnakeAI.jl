module SnakeAI

using GameZero

export play_snake, 
    Game, 
    play_step

function play_snake()
    GameZero.rungame("src/extras/HumanPlayableSnake.jl")
end

include("utils.jl")
include("point.jl")
include("snake.jl")
include("game.jl")

end
