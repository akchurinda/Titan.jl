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

    # Compute the number of nodes:
    nn = length(model.n)

    # Get the free and supported DOF indices:
    f_dofs, s_dofs = partition_idx(model)

    # Assemble the initial global force vector and partition it:
    F = assemble_F(model)
    F_f = F[f_dofs]
    F_s = F[s_dofs]

    # Preallocate the reference global force vector at the free DOFs:
    P̄_f = copy(F_f)

    # Preallocate the global force vector at the free DOFs to accumulate the applied loads:
    P_f = zero(F_f)

    # Preallocate the global residual force vector at the free DOFs:
    R_f = zero(F_f)

    # Preallocate the global displacement vector at the supported DOFs:
    δU_s = zero(F_s)

    # Preallocate the global reaction vector at the supported DOFs to accumulate the reactions:
    δR_f = zero(F_f)

    λ = 0

    i = 1
    while i <= max_num_i
        j = 1
        converged = false
        while j ≤ max_num_j && converged == false
            if j == 1
                # Assemble the global tangent stiffness matrix:
                K_e = assemble_K_e(model)
                K_g = assemble_K_g(model)
                K_t = K_e + K_g

                # Partition the global tangent stiffness matrix:
                global K_t_ff, _, K_t_sf, _ = partition(K_t, f_dofs, s_dofs)

                # Compute the displacement increment due to the reference load vector at the free DOFs:
                global δU_p_f = K_t_ff \ P̄_f
            end

            # Compute the displacement increment due to the residual force vector at the free DOFs:
            δU_r_f = K_t_ff \ R_f

            # Compute the load factor increment:
            a, b, c = coefficients(solver, nn, f_dofs, j)
            δλ = constraint(a, b, c, δU_p_f, δU_r_f)
            
            # Compute the displacement increment at the free DOFs:
            λ += δλ

            # Update the global force vector at the free DOFs:
            P_f += δλ * P̄_f

            # Update the global displacement vector at the free DOFs:
            δU_f = δλ * δU_p_f + δU_r_f

            # Assemble the full global displacement vector:
            δU = departition(δU_f, δU_s, f_dofs, s_dofs)

            # Compute the reaction vector incerement at the supported DOFs:
            δR_s = K_t_sf * δU_f

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
            Q = zeros(promote_type([eltype(e.state.f_l) for e in values(model.e)]...), 3 * nn)
            for e in values(model.e)
                idx_i = only(findall(keys(model.n) .== e.n_i_id))
                idx_j = only(findall(keys(model.n) .== e.n_j_id))

                f_l = e.state.f_l
                f_g = transform_l_to_g(f_l, e.state.Γ)

                Q[(3 * idx_i - 2):(3 * idx_i)] += f_g[1:3]
                Q[(3 * idx_j - 2):(3 * idx_j)] += f_g[4:6]
            end

            # Partition the global internal force vector:
            Q_f = Q[f_dofs]

            # Compute the global residual force vector at the free DOFs:
            R_f = P_f - Q_f

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