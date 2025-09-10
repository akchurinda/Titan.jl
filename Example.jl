using Titan
using CairoMakie

model = Model()

node!(model, 1,     0.0, 0.0)
node!(model, 2,  8000.0, 0.0)
node!(model, 3, 10000.0, 0.0)
node!(model, 4, 13000.0, 0.0)

material!(model, 1, 200)

section!(model, 1, 6E3, 200E6)
section!(model, 2, 4E3,  50E6)

element!(model, 1, 1, 2, 1, 1)
element!(model, 2, 2, 3, 1, 2)
element!(model, 3, 3, 4, 1, 2)

support!(model, 1, false, true, false)
support!(model, 2, false, true, false)
support!(model, 4, true, true, true)

cload!(model, 3, 0, -20, 0)
dload!(model, 1, 0, -2 / 1000)

analyze!(model, NonlinearElasticAnalysis(LoadControl(0.1), 10, 100, 1E-3))

begin
    F = Figure()

    A = Axis(F[1, 1])

    plotundeformed!(A, model, label = "Undeformed")
    plotdeformed!(A, model, label = "Deformed")

    display(F)
end