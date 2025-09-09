# Example #4.9, p. 80

using Titan
using ForwardDiff
using ReverseDiff
using FiniteDiff

function f(x)
    model = Model()

    node!(model, 1, x[1], x[4])
    node!(model, 2, x[2], x[5])
    node!(model, 3, x[3], x[6])

    material!(model, 1, 200000)

    section!(model, 1, 6E3, 200E6)
    section!(model, 2, 4E3,  50E6)

    element!(model, 1, 1, 2, 1, 1)
    element!(model, 2, 2, 3, 1, 2)

    support!(model, 1, true, true, true)
    support!(model, 2, false, true, false)

    cload!(model, 3, +5000 / sqrt(2), -5000 / sqrt(2), 0)

    U, _ = analyze(model)

    return U[end - 1]
end

@time ForwardDiff.gradient(f, [0.0, 8000.0, 13000.0, 0.0, 0.0, 0.0])
@time ReverseDiff.gradient(f, [0.0, 8000.0, 13000.0, 0.0, 0.0, 0.0])
@time FiniteDiff.finite_difference_gradient(f, [0.0, 8000.0, 13000.0, 0.0, 0.0, 0.0])