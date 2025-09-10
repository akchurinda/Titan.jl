@kwdef struct Model
    n::OrderedDict{Int, Node    } = OrderedDict{Int, Node    }()
    m::OrderedDict{Int, Material} = OrderedDict{Int, Material}()
    s::OrderedDict{Int, Section } = OrderedDict{Int, Section }()
    e::OrderedDict{Int, Element } = OrderedDict{Int, Element }()
end

function node!(model::Model, id::Int, x::Real, y::Real)
    haskey(model.n, id) && throw(ArgumentError("Node with ID $(id) already exists."))

    n = Node(x, y)
    model.n[id] = n

    return model
end

function material!(model::Model, id::Int, E::Real)
    haskey(model.m, id) && throw(ArgumentError("Material with ID $(id) already exists."))

    m = Material(E)
    model.m[id] = m

    return model
end

function section!(model::Model, id::Int, A::Real, I::Real)
    haskey(model.s, id) && throw(ArgumentError("Section with ID $(id) already exists."))

    s = Section(A, I)
    model.s[id] = s

    return model
end

function element!(model::Model, id::Int, n_i_id::Int, n_j_id::Int, m_id::Int, s_id::Int)
    haskey(model.e, id) && throw(ArgumentError("Element with ID $(id) already exists."))

    haskey(model.n, n_i_id) || throw(ArgumentError("Node with ID $(node_i_id) does not exist."))
    haskey(model.n, n_j_id) || throw(ArgumentError("Node with ID $(node_j_id) does not exist."))
    haskey(model.m, m_id  ) || throw(ArgumentError("Material with ID $(material_id) does not exist."))
    haskey(model.s, s_id  ) || throw(ArgumentError("Section with ID $(section_id) does not exist."))

    n_i = model.n[n_i_id]
    n_j = model.n[n_j_id]
    m   = model.m[m_id]
    s   = model.s[s_id]

    e = Element(n_i_id, n_j_id, n_i, n_j, m, s)
    model.e[id] = e

    return model
end

function support!(model::Model, id::Int, u_x_supp::Bool, u_y_supp::Bool, θ_z_supp::Bool)
    haskey(model.n, id) || throw(ArgumentError("Node with ID $(id) does not exist."))

    n = model.n[id]

    n.state.supports = @SVector [u_x_supp, u_y_supp, θ_z_supp]

    return model
end

function cload!(model::Model, id::Int, F_x::Real, F_y::Real, M_z::Real)
    haskey(model.n, id) || throw(ArgumentError("Node with ID $(id) does not exist."))

    n = model.n[id]

    n.state.f += @SVector [F_x, F_y, M_z]

    return model
end

function dload!(model::Model, id::Int, q_x::Real, q_y::Real)
    haskey(model.e, id) || throw(ArgumentError("Element with ID $(id) does not exist."))

    e = model.e[id]
    L = e.state.L
    Γ = e.state.Γ

    f_l = @SVector [
        +q_x * L / 2,
        +q_y * L / 2,
        +q_y * L ^ 2 / 12,
        +q_x * L / 2,
        +q_y * L / 2,
        -q_y * L ^ 2 / 12]

    f_g = transform_l_to_g(f_l, Γ)

    f_i = f_g[1:3]
    f_j = f_g[4:6]

    e.n_i.state.f += f_i
    e.n_j.state.f += f_j

    return model
end