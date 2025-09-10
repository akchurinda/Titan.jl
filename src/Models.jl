@kwdef struct Model
    n::Vector{Node    } = Vector{Node    }()
    m::Vector{Material} = Vector{Material}()
    s::Vector{Section } = Vector{Section }()
    e::Vector{Element } = Vector{Element }()

    _n_ids::Vector{Int} = Vector{Int}()
    _m_ids::Vector{Int} = Vector{Int}()
    _s_ids::Vector{Int} = Vector{Int}()
    _e_ids::Vector{Int} = Vector{Int}()
end

function node!(model::Model, id::Int, x::Real, y::Real)
    if id in model._n_ids
        error("Node with id $(id) already exists.")
    else
        push!(model._n_ids, id)
    end

    n = Node(x, y)
    push!(model.n, n)

    return model
end

function material!(model::Model, id::Int, E::Real)
    if id in model._m_ids
        error("Material with id $(id) already exists.")
    else
        push!(model._m_ids, id)
    end

    m = Material(E)
    push!(model.m, m)

    return model
end

function section!(model::Model, id::Int, A::Real, I::Real)
    if id in model._s_ids
        error("Section with id $(id) already exists.")
    else
        push!(model._s_ids, id)
    end

    s = Section(A, I)
    push!(model.s, s)

    return model
end

function element!(model::Model, id::Int, n_i_id::Int, n_j_id::Int, m_id::Int, s_id::Int)
    if id in model._e_ids
        error("Element with id $(id) already exists.")
    else
        push!(model._e_ids, id)
    end

    if !(n_i_id in model._n_ids)
        error("Node with id $(node_i_id) does not exist.")
    end

    if !(n_j_id in model._n_ids)
        error("Node with id $(node_j_id) does not exist.")
    end

    if !(m_id in model._m_ids)
        error("Material with id $(material_id) does not exist.")
    end

    if !(s_id in model._s_ids)
        error("Section with id $(section_id) does not exist.")
    end

    n_i = only(model.n[model._n_ids .== n_i_id])
    n_j = only(model.n[model._n_ids .== n_j_id])
    m   = only(model.m[model._m_ids .== m_id])
    s   = only(model.s[model._s_ids .== s_id])

    e = Element(n_i, n_j, m, s)
    push!(model.e, e)

    return model
end

function support!(model::Model, id::Int, u_x_supp::Bool, u_y_supp::Bool, θ_z_supp::Bool)
    if !(id in model._n_ids)
        error("Node with id $(id) does not exist.")
    end

    n = only(model.n[model._n_ids .== id])

    n.state.supports = @SVector [u_x_supp, u_y_supp, θ_z_supp]

    return model
end

function cload!(model::Model, id::Int, F_x::Real, F_y::Real, M_z::Real)
    if !(id in model._n_ids)
        error("Node with id $(id) does not exist.")
    end

    n = only(model.n[model._n_ids .== id])

    n.state.f += @SVector [F_x, F_y, M_z]

    return model
end

function dload!(model::Model, id::Int, q_x::Real, q_y::Real, m_z::Real, cs::Symbol)
    return model
end