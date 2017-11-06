function [Gprime] = plot_subgraph_and_neighbors(G,verts)

neighbs = [];
for j = 1:length(verts)
    neighbs = [neighbs; neighbors(G,verts(j))];
end
neighbs = setdiff(unique(neighbs), verts);

sub_nodes = [verts; neighbs];
if length(sub_nodes) <= 1000
    Gprime = subgraph(G,[verts; neighbs]);
    h = plot(Gprime,'Layout','force');
    highlight(h,1:length(verts),'NodeColor','g')
else
    text(0,0.5,sprintf('Graph too large to draw: %d vertices', length(sub_nodes)),'FontSize',18);
end
end