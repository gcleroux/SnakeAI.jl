import CUDA: cpu

# Constans for the game
const BLOCK_SIZE = 20
const WIDTH = 640
const HEIGHT = 480

@enum Direction begin
    UP = 1
    RIGHT = 2
    DOWN = 3
    LEFT = 4
end

# Constants for the agent
const MAX_MEMORY = 100_000
const BATCH_SIZE = 1000
const LR = 1e-3

# Constants for the model
const device = cpu

const MODELS_PATH = "saved_models"