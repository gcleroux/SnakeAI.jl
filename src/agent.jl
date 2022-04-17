using DataStructures: CircularBuffer

mutable struct Agent{T <: Integer}
    n_games::T
    ϵ::T  # Randomness
    γ::T  # Discount rate
    memory::CircularBuffer{T}
    # TODO: model, trainer

    function Agent()
        new{Int}(0, 0, 0, CircularBuffer{Int}(MAX_MEMORY))
    end
end

function get_state(game)

end

function remember(state, action, reward, next_state, done)
    
end

function train_short_memory(state, action, reward, next_state, done)

end

function train_long_memory()

end

function get_action(state)

end

function train()
    plot_scores = Int[]
    plot_mean_scores = []
    total_score = 0
    record = 0
    agent = Agent()
    game = SnakeAI.Game()

    while true
        old_state = get_state(game)

        # Get the move
        final_move = get_action(old_state)

        # Perform the move
        game.direction = final_move
        play_step!(game)    # Maybe return: score, reward, done?
        new_state = get_state(game)

        # Train the short memory
        train_short_memory(old_state, final_move, reward, new_state, done)

        # Remember
        remember(old_state, final_move, reward, new_state, done)
    
        if done
            # Reset the game
            reset!(game)
            agent.n_games += 1
            train_long_memory()

            if score > agent.record
                agent.record = score
                # TODO: save the model
            end
        end
        
        # TODO: Plotting the results
    
    end

end

