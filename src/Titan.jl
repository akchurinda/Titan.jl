module Titan
using StaticArrays
using LinearAlgebra

export Model
export node!, material!, section!, element!, support!, cload!, dload!
export LinearElasticAnalysis, NonlinearElasticAnalysis
export analyze!
export get_node_u, get_node_r, get_element_u_l, get_element_f_l

include("States.jl")
include("Nodes.jl")
include("Materials.jl")
include("Sections.jl")
include("Elements.jl")
include("Models.jl")
include("Utilities.jl")
include("Assembling.jl")
include("Analysis.jl")
include("Postprocessing.jl")
end