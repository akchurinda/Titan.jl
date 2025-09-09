mutable struct Node
    const x::Real
    const y::Real

    u_x_supp::Bool
    u_y_supp::Bool
    θ_z_supp::Bool
    
    F_x::Real
    F_y::Real
    M_z::Real

    Node(x::Real, y::Real) = new(x, y, false, false, false, 0, 0, 0)
end