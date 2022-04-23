import SnakeAI
using ProgressBars

function play_snake()
    rungame("src/extras/HumanPlayableSnake.jl")
end

function demo_agent()
    rungame("src/extras/AgentPlayedSnake.jl")
end

function train_agent(agent::SnakeAI.AbstractAgent; N::Int=150)

    # Creating the initial game
    game = SnakeAI.Game()

    iter = ProgressBar(1:N)
    set_description(iter, "Training the agent on $N games")

    for _ in iter
        done = false

        while !done
            done = train!(agent, game)
        end
    end

    @info "Agent high score after $N games => $(agent.record) pts"
end