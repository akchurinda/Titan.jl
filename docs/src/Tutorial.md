# Tutorial

## Defining Models

To quickly get you started with `Titan.jl`, let us recreate a simple example of a cantilever beam subjected to a distributed load.

First of all, load the package using the following command:

```@example tutorial
using Titan
```

To create a new model, use the `Model()` constructor:

```@example tutorial
model = Model()
```

To add nodes, use the `node!()` function:

```@example tutorial
node!(model,  1,  0 * 12, 0)
node!(model,  2,  1 * 12, 0)
node!(model,  3,  2 * 12, 0)
node!(model,  4,  3 * 12, 0)
node!(model,  5,  4 * 12, 0)
node!(model,  6,  5 * 12, 0)
node!(model,  7,  6 * 12, 0)
node!(model,  8,  7 * 12, 0)
node!(model,  9,  8 * 12, 0)
node!(model, 10,  9 * 12, 0)
node!(model, 11, 10 * 12, 0)
```

To add supports to the model, use `support!()` function:

```@example tutorial
support!(model, 1, true, true, true)
```

To add sections to the model, use the `section!()` function:

```@example tutorial
section!(model, 1, 9.16, 180)
```

To add materials to the model, use the `material!()` function:

```@example tutorial
material!(model, 1, 29000)
```

To add elements to the model, use the `element!()` function:

```@example tutorial
element!(model,  1,  1,  2, 1, 1)
element!(model,  2,  2,  3, 1, 1)
element!(model,  3,  3,  4, 1, 1)
element!(model,  4,  4,  5, 1, 1)
element!(model,  5,  5,  6, 1, 1)
element!(model,  6,  6,  7, 1, 1)
element!(model,  7,  7,  8, 1, 1)
element!(model,  8,  8,  9, 1, 1)
element!(model,  9,  9, 10, 1, 1)
element!(model, 10, 10, 11, 1, 1)
```

To add distributed loads to the model, use the `dload!()` function:

```@example tutorial
dload!(model,  1, 0, -1)
dload!(model,  2, 0, -1)
dload!(model,  3, 0, -1)
dload!(model,  4, 0, -1)
dload!(model,  5, 0, -1)
dload!(model,  6, 0, -1)
dload!(model,  7, 0, -1)
dload!(model,  8, 0, -1)
dload!(model,  9, 0, -1)
dload!(model, 10, 0, -1)
```

## Performing Analysis

To perform linear elastic analysis, use the `analyze!()` function:

```@example tutorial
analyze!(model, LinearElasticAnalysis())
```

## Plotting Undeformed and Deformed Models

To plot the undeformed and deformed models, load the `CairoMakie` function:

```@example tutorial
using CairoMakie

CairoMakie.activate!(type = :svg) # hide
CairoMakie.set_theme!(theme_latexfonts()) # hide
```

To plot the deformed and undeformed models use `plotundeformed()` and `plotdeformed()` functions, respectively.

```@example tutorial
begin
    F = Figure()

    A = Axis(F[1, 1])

    # Plot the undeformed model:
    plotundeformed!(A, model, label = "Undeformed")

    # Plot the deformed model:
    plotdeformed!(A, model, label = "Deformed")

    axislegend(A, position = :lb)

    F
end
```