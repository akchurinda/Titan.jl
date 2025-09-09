push!(LOAD_PATH, "../src/")

using Documenter
using Titan

makedocs(
    sitename = "Titan.jl",
    authors = "Damir Akchurin",
    pages = [
        "Home" => "index.md"])

deploydocs(
    repo = "github.com/akchurinda/Titan.jl")