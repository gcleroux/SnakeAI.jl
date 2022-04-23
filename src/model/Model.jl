module Model

import BSON: @save
import Flux
import ..SnakeAI: MODELS_PATH

export linear_QNet,
    save_model

function save_model(name::AbstractString, model::Flux.Chain)
    @save joinpath(MODELS_PATH, name) model
    return
end

include("models.jl")

end # module