# SnakeAI

![Image of a game of Snake](https://github.com/gcleroux/SnakeAI.jl/blob/main/assets/Snake.png "A Game of Snake")

This is a small personal project which goal is to make a reinforcement learning agent learn how to play snake effectively.

The code is strongly inspired by the tutorials of [Python Engineer](https://www.youtube.com/watch?v=PJl4iabBEz0&list=PLqnslRFeH2UrDh7vUmJ60YrmWd64mTTKV).

## Get Started
To install and run this project, follow theses instructions:

1. Clone the repository
```
$ git clone https://github.com/gcleroux/SnakeAI.jl
```

2. cd into the project
```
$ cd SnakeAI.jl/
```

3. Installing deps

```julia
julia> using Pkg

julia> Pkg.activate(".")

julia> Pkg.instantiate()

julia> using SnakeAI
```

## Using the package
There are two ways of using this package currently. You can play Snake yourself or train an agent to play.

To play a game of Snake yourself, enter the follwing commands in the REPL:

```julia
julia> play_snake()
```

To visualize an agent's training, enter the follwing commands in the REPL:

```julia
julia> demo_agent()
```
You can create your own agent with the `Agent` interface. Once created, you can
use the `train_agent` function to benchmark it's performance:

```julia
julia> my_agent = SnakeAgent(args...)

julia> train_agent(my_agent)
```
