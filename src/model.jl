import BSON: @save
import Flux: Dense, Chain, relu

function create_linear_QNet(input_size::T, hidden_size::T, output_size::T) where {T<:Integer}
    # Creating the model
    model = Chain(
		# First linear layer
		Dense(input_size => hidden_size, relu),

        # Second linear layer
		Dense(hidden_size => output_size)
    )

    return model
end

function save_model(name::AbstractString, model)
    @save joinpath(MODELS_PATH, name) model
    return
end