function closest_vertices = find_closest_vertices_to(G,s)

% SPT on modified graph to find the closest vertices in A to s.
n = height(G.Nodes);
Gp = addnode(G,n+1);
Gp = addedge(Gp, (n+1)*ones(1,length(s)), s, ones(1,length(s)));
T = bfsearch(Gp,n+1,'edgetonew');
closest_vertices = zeros(1,n);
closest_vertices(s) = s;
for i = (length(s)+1):size(T,1)
    closest_vertices(T(i,2)) = closest_vertices(T(i,1));
end
end