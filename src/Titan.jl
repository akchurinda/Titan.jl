module Titan
using StaticArrays
using LinearAlgebra
using OrderedCollections
using StyledStrings
using Printf

export Model
export node!, material!, section!, element!, support!, cload!, dload!
export LinearElasticAnalysis, NonlinearElasticAnalysis
export analyze!
export get_node_u, get_node_r, get_element_u_l, get_element_f_l
export plotundeformed, plotundeformed!, plotdeformed, plotdeformed!

include("Components/States/NodeStates.jl")
include("Components/States/ElementStates.jl")
include("Components/Nodes.jl")
include("Components/Materials.jl")
include("Components/Sections.jl")
include("Components/Elements.jl")
include("Models.jl")
include("Analysis/Analysis.jl")
include("Postprocessing/ExtractingResults.jl")
include("Postprocessing/PlottingResults.jl")
include("Utilities.jl")
end