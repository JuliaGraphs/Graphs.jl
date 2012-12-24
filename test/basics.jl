require("Graphs")
using Graphs

n1 = Node(1, "A")
n2 = Node(2, "B")

nodes = [n1, n2]

e1 = Edge(n1, n2, utf8(""))

edges = [e1]

g = Graph(nodes, edges)

numeric_nodes = [1 2;
                 1 3;
                 2 3;]
node_names = UTF8String["A", "B", "C"]

g = Graph(numeric_nodes, node_names)

m = ["a" "b";
     "a" "c";
     "b" "c";]

g = Graph(m)

adjacency_matrix(g)
