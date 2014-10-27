# the show function for general graphs

function show(io::IO, v::ExVertex)
    if isempty(v.label)
        print(io, "vertex [$(v.index)]")
    else
        print(io, "vertex [$(v.index)] \"$(v.label)\"")
    end
end

function show(io::IO, e::Union(Edge, ExEdge))
    print(io, "edge [$(e.index)]: $(e.source) -- $(e.target)")
end

function show(io::IO, graph::AbstractGraph)
    title = is_directed(graph) ? "Directed Graph" : "Undirected Graph"
    print(io, "$title ($(num_vertices(graph)) vertices, $(num_edges(graph)) edges)")
end

function show_details(io::IO, graph::AbstractGraph)
    title = is_directed(graph) ? "Directed Graph" : "Undirected Graph"
    println(io, "$title with $(num_vertices(graph)) vertices and $(num_edges(graph)) edges:")

    if !implements_vertex_list(graph)
        return
    end

    if implements_incidence_list(graph)
        println(io, "Incidence List:")
        for v in vertices(graph)
            println(io, "$(v): ")
            for e in out_edges(v, graph)
                print(io, "    ")
                println(io, e)
            end
        end

    elseif implements_adjacency_list(graph)
        println(io, "Adjacency List:")
        for v in vertices(graph)
            println(io, "$(v): ")
            for u in out_neighbors(v, graph)
                print(io, "    ")
                println(io, "$v -- $u")
            end
        end

    else
        println(io, "Vertices:")
        for v in vertices(graph)
            println(io, "$(v)")
        end

        if implements_edge_list(graph)
            println(io, "Edges:")
            for e in edges(graph)
                println(io, "$(e)")
            end
        end
    end
end
