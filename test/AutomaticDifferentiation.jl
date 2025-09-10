@testset "Cantilever beam subjected to concentrated load: Linear elastic analysis" begin
    # Define the problem parameters:
    L = 120   # in.
    I = 100   # in.⁴
    E = 29000 # ksi
    P = 100   # kip
    t = float.([L, I, E, P])

    # Define the function to be differentiated:
    function f(t::AbstractVector{<:Real})::Real
        # Extract the problem parameters:
        L, I, E, P = t

        # Define an empty model:
        model = Model()

        # Define the nodes and DOF supports:
        for (i, x) in enumerate(range(0, L, 11))
            if i == 1
                node!(model, i, x, 0)
                support!(model, i, true, true, true)
            else
                node!(model, i, x, 0)
            end
        end

        # Define the sections:
        section!(model, 1, 1, I)

        # Define the materials:
        material!(model, 1, E)

        # Define the elements:
        for i in 1:10
            element!(model, i, i, i + 1, 1, 1)
        end

        # Define the loads:
        cload!(model, 11, 0, -P, 0)

        # Solve the model using a linear elastic analysis:
        analyze!(model, LinearElasticAnalysis())

        # Extract the vertical displacement of free end of the cantilever beam:
        Δ = get_node_u(model, 11)[2]

        # Return the vertical displacement of the free end of the cantilever beam:
        return Δ
    end

    # Define the exact solution:
    function g(t::AbstractVector{<:Real})::Real
        # Extract the problem parameters:
        L, I, E, P = t

        # Compute the vertical displacement of the free end of the cantilever beam:
        Δ = -(P * L ^ 3) / (3 * E * I)

        # Return the vertical displacement of the free end of the cantilever beam:
        return Δ
    end

    # Check:
    @test f(t) ≈ g(t) rtol = 1E-3

    # Preallocate the gradient vector:
    ∇f = similar(t)
    ∇g = similar(t)

    # Compute the gradient vector using FiniteDiff.jl:
    gradient!(f, ∇f, AutoFiniteDiff(), t)
    gradient!(g, ∇g, AutoFiniteDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ForwardDiff.jl:
    gradient!(f, ∇f, AutoForwardDiff(), t)
    gradient!(g, ∇g, AutoForwardDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ReverseDiff.jl:
    gradient!(f, ∇f, AutoReverseDiff(), t)
    gradient!(g, ∇g, AutoReverseDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3
end

@testset "Cantilever beam subjected to distributed load: Linear elastic analysis" begin
    # Define the problem parameters:
    L = 120   # in.
    I = 100   # in.⁴
    E = 29000 # ksi
    w = 10    # kip / in.
    t = float.([L, I, E, w])

    # Define the function to be differentiated:
    function f(t::AbstractVector{<:Real})::Real
        # Extract the problem parameters:
        L, I, E, w = t

        # Define an empty model:
        model = Model()

        # Define the nodes and DOF supports:
        for (i, x) in enumerate(range(0, L, 11))
            if i == 1
                node!(model, i, x, 0)
                support!(model, i, true, true, true)
            else
                node!(model, i, x, 0)
            end
        end

        # Define the sections:
        section!(model, 1, 1, I)

        # Define the materials:
        material!(model, 1, E)

        # Define the elements:
        for i in 1:10
            element!(model, i, i, i + 1, 1, 1)
        end

        # Define the loads:
        for i in 1:10
            dload!(model, i, 0, -w)
        end

        # Solve the model using a linear elastic analysis:
        analyze!(model, LinearElasticAnalysis())

        # Extract the vertical displacement of free end of the cantilever beam:
        Δ = get_node_u(model, 11)[2]

        # Return the vertical displacement of the free end of the cantilever beam:
        return Δ
    end

    # Define the exact solution:
    function g(t::AbstractVector{<:Real})::Real
        # Extract the problem parameters:
        L, I, E, w = t

        # Compute the vertical displacement of the free end of the cantilever beam:
        Δ = -(w * L ^ 4) / (8 * E * I)

        # Return the vertical displacement of the free end of the cantilever beam:
        return Δ
    end

    # Check:
    @test f(t) ≈ g(t) rtol = 1E-3

    # Preallocate the gradient vector:
    ∇f = similar(t)
    ∇g = similar(t)

    # Compute the gradient vector using FiniteDiff.jl:
    gradient!(f, ∇f, AutoFiniteDiff(), t)
    gradient!(g, ∇g, AutoFiniteDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ForwardDiff.jl:
    gradient!(f, ∇f, AutoForwardDiff(), t)
    gradient!(g, ∇g, AutoForwardDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ReverseDiff.jl:
    gradient!(f, ∇f, AutoReverseDiff(), t)
    gradient!(g, ∇g, AutoReverseDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3
end

@testset "Denavit and Hajjar (2013): Cantilever under axial and transverse loading: Linear elastic analysis" begin
    L = 120   # in.
    A = 9.12  # in.²
    I = 110   # in.⁴
    E = 29000 # ksi
    H = 50    # kip
    V = 1     # kip
    t = float.([L, A, I, E, H, V])

    function f(t::AbstractVector{<:Real})
        L, A, I, E, H, V = t

        # Define an empty model:
        model = Model()

        # Define the nodes and DOF supports:
        for (i, x) in enumerate(range(0, L, 11))
            if i == 1
                node!(model, i, x, 0)
                support!(model, i, true, true, true)
            else
                node!(model, i, x, 0)
            end
        end

        # Define the sections:
        section!(model, 1, A, I)

        # Define the materials:
        material!(model, 1, E)

        # Define the elements:
        for i in 1:10
            element!(model, i, i, i + 1, 1, 1)
        end

        # Define the loads:
        cload!(model, 11, -H, -V, 0)

        # Solve the model using a linear elastic analysis:
        analyze!(model, LinearElasticAnalysis())

        # Extract the vertical displacement of free end of the cantilever beam:
        y_max = get_node_u(model, 11)[2]

        # Extract the result:
        return y_max
    end

    function g(t::AbstractVector{<:Real})
        L, A, I, E, H, V = t

        y_max = -(V * L ^ 3) / (3 * E * I)

        return y_max
    end

    # Check:
    @test f(t) ≈ g(t) rtol = 1E-3

    # Preallocate the gradient vector:
    ∇f = similar(t)
    ∇g = similar(t)

    # Compute the gradient vector using FiniteDiff.jl:
    gradient!(f, ∇f, AutoFiniteDiff(), t)
    gradient!(g, ∇g, AutoFiniteDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ForwardDiff.jl:
    gradient!(f, ∇f, AutoForwardDiff(), t)
    gradient!(g, ∇g, AutoForwardDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ReverseDiff.jl:
    gradient!(f, ∇f, AutoReverseDiff(), t)
    gradient!(g, ∇g, AutoReverseDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3
end

@testset "Denavit and Hajjar (2013): Cantilever under axial and transverse loading: Nonlinear elastic analysis" begin
    L = 120   # in.
    A = 9.12  # in.²
    I = 110   # in.⁴
    E = 29000 # ksi
    H = 50    # kip
    V = 1     # kip
    t = float.([L, A, I, E, H, V])

    function f(t::AbstractVector{<:Real})
        L, A, I, E, H, V = t

        # Define an empty model:
        model = Model()

        # Define the nodes and DOF supports:
        for (i, x) in enumerate(range(0, L, 11))
            if i == 1
                node!(model, i, x, 0)
                support!(model, i, true, true, true)
            else
                node!(model, i, x, 0)
            end
        end

        # Define the sections:
        section!(model, 1, A, I)

        # Define the materials:
        material!(model, 1, E)

        # Define the elements:
        for i in 1:10
            element!(model, i, i, i + 1, 1, 1)
        end

        # Define the loads:
        cload!(model, 11, -H, -V, 0)

        # Solve the model using a linear elastic analysis:
        analyze!(model, NonlinearElasticAnalysis(LoadControl(1 / 100), 100, 100, 1E-6))

        # Extract the vertical displacement of free end of the cantilever beam:
        y_max = get_node_u(model, 11)[2]

        # Extract the result:
        return y_max
    end

    function g(t::AbstractVector{<:Real})
        L, A, I, E, H, V = t

        α = sqrt((H * L ^ 2) / (E * I))
        y_max = -(V * L ^ 3) / (3 * E * I) * ((3 * (tan(α) - α)) / (α ^ 3))

        return y_max
    end

    # Check:
    @test f(t) ≈ g(t) rtol = 1E-3

    # Preallocate the gradient vector:
    ∇f = similar(t)
    ∇g = similar(t)

    # Compute the gradient vector using FiniteDiff.jl:
    gradient!(f, ∇f, AutoFiniteDiff(), t)
    gradient!(g, ∇g, AutoFiniteDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ForwardDiff.jl:
    gradient!(f, ∇f, AutoForwardDiff(), t)
    gradient!(g, ∇g, AutoForwardDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3

    # Compute the gradient vector using ReverseDiff.jl:
    gradient!(f, ∇f, AutoReverseDiff(), t)
    gradient!(g, ∇g, AutoReverseDiff(), t)
    @test ∇f ≈ ∇g rtol = 1E-3
end