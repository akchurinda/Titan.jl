struct Node
    x::Real
    y::Real
    state::NodeState

    Node(x::Real, y::Real) = new(x, y, NodeState())
end