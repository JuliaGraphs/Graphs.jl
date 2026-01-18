"""
    eigenvector_centrality(g)

Compute the eigenvector centrality for the graph `g`.

Eigenvector centrality computes the centrality for a node based on the
centrality of its neighbors. The eigenvector centrality for node `i` is
the \$i^{th}\$ element of \$\\mathbf{x}\$ in the equation
``
    \\mathbf{Ax} = λ \\mathbf{x}
``
where \$\\mathbf{A}\$ is the adjacency matrix of the graph `g` 
with eigenvalue λ.

By virtue of the Perron–Frobenius theorem, there is a unique and positive
solution if λ is the largest eigenvalue associated with the
eigenvector of the adjacency matrix \$\\mathbf{A}\$.

### References

- [bonacich1987power](@cite)
- [datta2012book](@cite)
"""
function eigenvector_centrality(g::AbstractGraph)
    return abs.(vec(eigs(adjacency_matrix(g); which=LM(), nev=1)[2]))::Vector{Float64}
end
