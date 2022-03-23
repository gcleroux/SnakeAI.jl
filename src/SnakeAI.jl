module SnakeAI
using GameZero

export play_snake

include("snakeGame.jl")

function play_snake()
    GameZero.rungame("src/snakeGame.jl")
end

end
