# Additional tests of the to_dot function

# This adds tests where:
#   1) there are isolated vertices
#   2) there are vertex attributes to be shown in .dot
#   3) the graph verifies implements_edge_list(.) == true
#      and                implements_vertex_map(.) == true


# These functions help with dealing with the fact that in two equivalent
# renderings of the same graph one may obtain equivalent .dots with permuted
# lines. This results of the fact that no ordering of vertices is implied by
# the code
#    ```for vtx in  vertices(graph) .... end```. For similar reasons,
#    attributes are extracted of a Dict in arbitrary order.
#
# So:
# 1) lines are sorted (result is independent of order in vertices and edges)
# 2) attributes are checksummed (with an order independent checksum (not a good
#    one)). This is not a precise verification of attributes, but good enough
#           for testing

# NOTE: if to_dot is modified to emit lines with .dot comments, these tests
#       mail fail erroneously....


comRX = Base.compile(r"^[^\[]+\[([^\[]+)\]\h*$"x)
function   rewriteAttrs(a::AbstractString)
     m = match(comRX,a)
     if m!=nothing
         attrs = m.captures[1]
         offset= m.offsets[1]
         chksum= mod(reduce(+,
                            map(x->convert(Int,x),collect(attrs)), init=0  ), 25)
         ch = convert(Char, convert(Int,'a') - 1 + chksum)
         a[1:offset-1] * "$ch" * a[ offset+length(attrs) : end ]
     else
         return a
     end
end

function  check_same_dot(a::AbstractString,b::AbstractString)
    sa=sort( map( rewriteAttrs, split( a, "\n")))
    sb=sort( map( rewriteAttrs, split( b, "\n")))
    la = map(rewriteAttrs,sa)
    lb = map(rewriteAttrs,sb)
    return   la==lb
end



module testDOT1

using Graphs
using Test


###########
#     test dot output for graphs for which
#         true == implements_edge_list && implements_vertex_map
#     and no vertex attributes
###########

### 1) graph without node attributes
sgd = simple_graph(3)

@test @show implements_edge_list(sgd)==true
@test @show implements_vertex_map(sgd)==true

add_vertex!(sgd)

dot1=to_dot(sgd)
println(dot1)
@test Main.check_same_dot(dot1,"digraph graphname {\n1\n2\n3\n4\n}\n")

### 2) graph without node attributes but with some edges
add_edge!(sgd,1,3)
add_edge!(sgd,3,1)
add_edge!(sgd,2,3)

dot2=to_dot(sgd)
println(dot2)
@test Main.check_same_dot(dot2,
                 "digraph graphname {\n1\n2\n3\n4\n1 -> 3\n3 -> 1\n2 -> 3\n}\n")


end # module testDOT1

module testDOT2

using Graphs
using Test

###########
#     test dot output for graphs for which
#         true == implements_edge_list && implements_vertex_map
#     and vertex attributes
###########

struct MyVtxType
    name::AbstractString
end

import Graphs.attributes
function Graphs.attributes(vtx::MyVtxType,g::G) where {G<:AbstractGraph}
     rd = Graphs.AttributeDict()
     rd["label"]=vtx.name
     rd["color"]="bisque"
     rd
end

### 3) directed graph with node attributes and some disconnected vertices

ag = Graphs.graph( map( MyVtxType,[ "a", "b", "c","d"]), Graphs.Edge{MyVtxType}[],
                      is_directed=true)

vl = ag.vertices

add_edge!(ag,  vl[1], vl[3] )
add_edge!(ag,  vl[3], vl[1] )
add_edge!(ag,  vl[2], vl[3])

@test @show implements_edge_list(ag)==true
@test @show implements_vertex_map(ag)==true

dot3 = to_dot( ag )
println(dot3)

compDot3 =  "digraph graphname {\n1\t[\"label\"=\"a\",\"color\"=\"bisque\"]\n2\t[\"label\"=\"b\",\"color\"=\"bisque\"]\n3\t[\"label\"=\"c\",\"color\"=\"bisque\"]\n4\t[\"label\"=\"d\",\"color\"=\"bisque\"]\n1 -> 3\n3 -> 1\n2 -> 3\n}\n"

@test Main.check_same_dot(dot3,compDot3)

### 4) undirected graph with node attributes and some disconnected vertices


agu = Graphs.graph( map( MyVtxType,[ "a", "b", "c","d"]), Graphs.Edge{MyVtxType}[],
                      is_directed=false)

vl = agu.vertices

add_edge!(agu, vl[1], vl[3] )
add_edge!(agu,  vl[2], vl[3])

dot4=to_dot(agu)
println(dot4)

@test @show implements_edge_list(agu)==true
@test @show implements_vertex_map(agu)==true

@test Main.check_same_dot(dot4,"graph graphname {\n1\t[\"label\"=\"a\",\"color\"=\"bisque\"]\n2\t[\"label\"=\"b\",\"color\"=\"bisque\"]\n3\t[\"label\"=\"c\",\"color\"=\"bisque\"]\n4\t[\"label\"=\"d\",\"color\"=\"bisque\"]\n1 -- 3\n2 -- 3\n}\n"
)

end # module testDOT2
