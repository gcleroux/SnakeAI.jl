import Flux: Dense, relu

function linear_QNet(input_size::T, hidden_size::T, output_size::T) where {T<:Integer}
    # Creating the model
    model = Flux.Chain(
		# First linear layer
		Dense(input_size => hidden_size, relu),

        # Second linear layer
		Dense(hidden_size => output_size)
    )

    return model
end