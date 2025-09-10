using Test
using Titan
using DifferentiationInterface, FiniteDiff, ForwardDiff, ReverseDiff

@testset verbose = true "Automatic differentiation"  include("AutomaticDifferentiation.jl")
@testset verbose = true "Denavit and Hajjar (2013)"  include("Denavit and Hajjar (2013).jl")