function [bridges, bridge_comps] = find_bridges(g_adj)
% Return a list of cut edges and 2-edge-connected components of G.
% This is the analogue of the biconnected components algorithm, but for
% edges instead of vertices. It is a bit slow, since it is written in
% native MATLAB.

assert(issparse(g_adj)); % g_adj is a sparse adjacency matrix.

n = size(g_adj,1);
vis = zeros(1,n);
low = zeros(1,n);
disc = zeros(1,n);
parent = zeros(1,n);
currch = zeros(1,n);
deg = sum(g_adj,1);

u = 1;
time = 0;

bridges = zeros(0,2);

while u ~= 0
  % disp(u)
   if currch(u) == 0   
    time = time + 1;
    vis(u) = 1;
    low(u) = time;
    disc(u) = time;
    currch(u) = currch(u) + 1;
   elseif currch(u) == deg(u) + 1
       u = parent(u);
   else
       neighbors = find(g_adj(u,:));
       v = neighbors(currch(u));
       if ~vis(v)
           parent(v) = u;
           u = v;
       else
           if v ~= parent(u)
            low(u) = min(low(u), disc(v));
           end
           if u == parent(v)
               low(u) = min(low(u), low(v));
               if low(v) > disc(u)
                   % [u v]
                   bridges = [bridges; [u v]];
               end
           end
           currch(u) = currch(u) + 1;
       end
   end
end