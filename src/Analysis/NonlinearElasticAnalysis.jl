abstract type AbstractNonlinearSolver end

struct LoadControl <: AbstractNonlinearSolver
    Δλ::Real
end

function coefficients(solver::LoadControl, nn, f_dofs, j)
    Δλ = solver.Δλ

    a = zeros(3 * nn)[f_dofs]
    b = 1
    c = j == 1 ? Δλ : 0

    return a, b, c
end

constraint(a, b, c, δu_p, δu_r) = (c - dot(a, δu_r)) / (dot(a, δu_p) + b)

struct NonlinearElasticAnalysis <: AbstractAnalysis 
    solver::AbstractNonlinearSolver
    max_num_i::Int
    max_num_j::Int
    ϵ::Real
end

function analyze!(model::Model, analysis::NonlinearElasticAnalysis)
    # Unpack the analysis parameters:
    solver = analysis.solver
    max_num_i = analysis.max_num_i
    max_num_j = analysis.max_num_j
    ϵ = analysis.ϵ

    T_K_e = promote_type([get_K_e_eltype(e) for e in values(model.e)]...)
    T_K_g = promote_type([get_K_g_eltype(e) for e in values(model.e)]...)
    T_F   = promote_type([get_F_eltype(n) for n in values(model.n)]...)
    T     = promote_type(T_K_e, T_K_g, T_F)

    # Get the free and supported DOF indices:
    f_dofs, s_dofs = partition_idx(model)
    n_f_dofs = count(f_dofs)
    n_s_dofs = count(s_dofs)
    t_n_dofs = n_f_dofs + n_s_dofs

    # Assemble the initial global force vector and partition it:
    F = assemble_F(model)
    F_f = F[f_dofs]

    P̄_f = copy(F_f)

    P_f    = zeros(T, n_f_dofs)
    R_f    = zeros(T, n_f_dofs)
    K_e    = zeros(T, t_n_dofs, t_n_dofs)
    K_g    = zeros(T, t_n_dofs, t_n_dofs)
    K_t    = zeros(T, t_n_dofs, t_n_dofs)
    K_t_ff = zeros(T, n_f_dofs, n_f_dofs)
    K_t_sf = zeros(T, n_s_dofs, n_f_dofs)
    δU_s   = zeros(T, n_s_dofs)
    δR_f   = zeros(T, n_f_dofs)
    δU_p_f = zeros(T, n_f_dofs)
    δU_r_f = zeros(T, n_f_dofs)
    δU_f   = zeros(T, n_f_dofs)
    δU     = zeros(T, n_f_dofs)
    δR_f   = zeros(T, n_f_dofs)
    δR_s   = zeros(T, n_s_dofs)
    δR     = zeros(T, n_f_dofs)
    Q_f    = zeros(T, n_f_dofs)
    Q      = zeros(T, t_n_dofs)

    λ = 0

    i = 1
    while i <= max_num_i
        j = 1
        converged = false
        while j ≤ max_num_j && converged == false
            if j == 1
                # Assemble the global tangent stiffness matrix:
                K_e .= assemble_K_e(model)
                K_g .= assemble_K_g(model)
                K_t .= K_e + K_g

                # Partition the global tangent stiffness matrix:
                K_t_ff .= K_t[f_dofs, f_dofs]
                K_t_sf .= K_t[s_dofs, f_dofs]

                # Compute the displacement increment due to the reference load vector at the free DOFs:
                δU_p_f .= K_t_ff \ P̄_f
            end

            # Compute the displacement increment due to the residual force vector at the free DOFs:
            δU_r_f .= K_t_ff \ R_f

            # Compute the load factor increment:
            if solver isa LoadControl
                δλ = j == 1 ? solver.Δλ : 0
            end
            
            # Compute the displacement increment at the free DOFs:
            λ += δλ

            # Update the global force vector at the free DOFs:
            P_f .+= δλ * P̄_f

            # Update the global displacement vector at the free DOFs:
            δU_f .= δλ .* δU_p_f .+ δU_r_f

            # Assemble the full global displacement vector:
            δU = departition(δU_f, δU_s, f_dofs, s_dofs)

            # Compute the reaction vector incerement at the supported DOFs:
            δR_s .= K_t_sf * δU_f

            # Assemble the full global reaction vector increment:
            δR = departition(δR_f, δR_s, f_dofs, s_dofs)

            # Update the states of the nodes:
            for (idx, n) in enumerate(values(model.n))
                n.state.u += @SVector [δU[3 * idx - 2], δU[3 * idx - 1], δU[3 * idx]]
                n.state.r += @SVector [δR[3 * idx - 2], δR[3 * idx - 1], δR[3 * idx]]
            end

            # Update the states of the elements:
            for e in values(model.e)
                x_i, y_i = e.n_i.x, e.n_i.y
                x_j, y_j = e.n_j.x, e.n_j.y

                u_i_g = get_node_u(model, e.n_i_id)
                u_j_g = get_node_u(model, e.n_j_id)
                u_g   = vcat(u_i_g, u_j_g)

                L     = compute_L(x_i + u_g[1], y_i + u_g[2], x_j + u_g[1], y_j + u_g[2])
                Γ     = compute_Γ(x_i + u_g[1], y_i + u_g[2], x_j + u_g[1], y_j + u_g[2], L)
                u_l   = transform_g_to_l(u_g, Γ)
                f_l   = (e.state.k_e_l + e.state.k_g_l) * u_l
                k_e_l = compute_k_e_l(e.m.E, e.s.A, e.s.I, L)
                k_g_l = compute_k_g_l(f_l[4], L)
                k_e_g = transform_l_to_g(k_e_l, Γ)
                k_g_g = transform_l_to_g(k_g_l, Γ)

                e.state.L     = L
                e.state.Γ     = Γ
                e.state.u_l   = u_l
                e.state.f_l   = f_l
                e.state.k_e_l = k_e_l
                e.state.k_g_l = k_g_l
                e.state.k_e_g = k_e_g
                e.state.k_g_g = k_g_g
            end

            # Compute the global internal force vector:
            Q .= 0
            for e in values(model.e)
                idx_i = only(findall(keys(model.n) .== e.n_i_id))
                idx_j = only(findall(keys(model.n) .== e.n_j_id))

                f_l = e.state.f_l
                f_g = transform_l_to_g(f_l, e.state.Γ)

                Q[(3 * idx_i - 2):(3 * idx_i)] += f_g[1:3]
                Q[(3 * idx_j - 2):(3 * idx_j)] += f_g[4:6]
            end

            # Partition the global internal force vector:
            Q_f .= Q[f_dofs]

            # Compute the global residual force vector at the free DOFs:
            R_f .= P_f .- Q_f

            # Check for convergence:
            if norm(R_f) / norm(P_f) < ϵ
                converged = true
            end

            j += 1
        end

        if converged == false
            @warn "Increment (i) did not converge in $max_num_j iterations."
        end

        i += 1
    end

    return model
end

struct ArcLengthControl <: AbstractNonlinearSolver
    Δs::Real
end

struct WorkControl <: AbstractNonlinearSolver
    ΔW::Real
end