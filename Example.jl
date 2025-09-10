# Example #4.9, p. 80

# using ForwardDiff
# using ReverseDiff
# using FiniteDiff

# function f(x)
#     model = Model()

#     node!(model, 1, x[1], x[4])
#     node!(model, 2, x[2], x[5])
#     node!(model, 3, x[3], x[6])

#     material!(model, 1, 200000)

#     section!(model, 1, 6E3, 200E6)
#     section!(model, 2, 4E3,  50E6)

#     element!(model, 1, 1, 2, 1, 1)
#     element!(model, 2, 2, 3, 1, 2)

#     support!(model, 1, true, true, true)
#     support!(model, 2, false, true, false)

#     cload!(model, 3, +5000 / sqrt(2), -5000 / sqrt(2), 0)

#     analyze!(model, LinearElasticAnalysis())

#     u = get_node_u(model, 3)[2]

#     return u
# end

# @time ForwardDiff.gradient(f, [0.0, 8000.0, 13000.0, 0.0, 0.0, 0.0])
# @time ReverseDiff.gradient(f, [0.0, 8000.0, 13000.0, 0.0, 0.0, 0.0])
# @time FiniteDiff.finite_difference_gradient(f, [0.0, 8000.0, 13000.0, 0.0, 0.0, 0.0])

using Titan
using CairoMakie

model = Model()

node!(model, 1,     0.0, 0.0)
node!(model, 2,  8000.0, 0.0)
node!(model, 3, 13000.0, 0.0)

material!(model, 1, 200)

section!(model, 1, 6E3, 200E6)
section!(model, 2, 4E3,  50E6)

element!(model, 1, 1, 2, 1, 1)
element!(model, 2, 2, 3, 1, 2)

support!(model, 1, true, true, true)
support!(model, 2, false, true, false)

cload!(model, 3, +5 / sqrt(2), -5 / sqrt(2), 0)

analyze!(model, LinearElasticAnalysis());

begin
    F = Figure()

    A = Axis(F[1, 1])

    plotundeformed!(A, model, label = "Undeformed")
    plotdeformed!(A, model, label = "Deformed")

    # axislegend(A)

    F
end