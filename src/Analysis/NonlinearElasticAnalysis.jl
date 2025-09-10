abstract type AbstractNonlinearSolver end

struct LoadControl <: AbstractNonlinearSolver
    Δλ::Real
end

struct DisplacementControl <: AbstractNonlinearSolver
    Δu::Real
end

struct ArcLengthControl <: AbstractNonlinearSolver
    Δs::Real
end

struct WorkControl <: AbstractNonlinearSolver
    ΔW::Real
end

function coefficients(solver::LoadControl) end
function coefficients(solver::DisplacementControl) end
function coefficients(solver::ArcLengthControl) end
function coefficients(solver::WorkControl) end

function constraint(solver::LoadControl, a, b, c, δu_p, δu_r) end
function constraint(solver::DisplacementControl, a, b, c, δu_p, δu_r) end
function constraint(solver::ArcLengthControl, a, b, c, δu_p, δu_r) end
function constraint(solver::WorkControl, a, b, c, δu_p, δu_r) end

struct NonlinearElasticAnalysis <: AbstractAnalysis 
    solver::NonlinearSolver
    max_num_i::Int
    max_num_j::Int
    ϵ::Real
end

function solve!(model::Model, analysis::NonlinearElasticAnalysis)
    
end