n = 400000;
samp = 1;
L = sqrt(n);
c = 4;
t = 1;

thresh = c;
pos = rand(n,2)*L;
pos(1,:) = [L/2 L/2];

GrphKDT = KDTreeSearcher(pos);
adj_list = rangesearch(GrphKDT,pos,thresh); % Get adj list.
templ = cellfun(@(x) length(x), adj_list); % THIS LINE IS A BOTTLENECK.
adj_list = [rldecode(templ, 1:n); adj_list{:}]';
adj_list = adj_list(adj_list(:,1) < adj_list(:,2),:); % List each edge once.
% Subsample edges:
adj_list = adj_list(rand(length(adj_list), 1) < t,:);
num_edges = length(adj_list(:,1));
A = sparse(adj_list(:,1), adj_list(:,2),1,n,n,num_edges); 
A = A + A';

g = graph(A);
disp('Graph generated.')

[sbincount,comp] = get_comp_sizes(g);
giant_idx = find(comp == 1);
disp(sbincount(1));

% s = giant_idx(1:samp);
s = 1:samp;
graph_d = distances(g, s); % Too large for n = 20000.
straight_d = zeros(samp, n);
for i = 1:length(s)
    s_val = s(i);
    straight_d(i,:) = sqrt((pos(s_val,1) - pos(:,1)).^2 + (pos(s_val,2) - pos(:,2)).^2);
end
sds = straight_d(:);
rats = graph_d ./ straight_d * c;
rats = rats(:);

% scatter(sds, rats);
% ylim([0 3]);
% line([0 max(sds)], [1 1]);
% xlim([0 max(sds)]);
cropped_density([sds rats], [10000 100], [0 max(sds) 1 1.2]);
h = gca;
h.YDir = 'normal';

% pause
% for i = 1:300
% histogram(rats(sds > i))
% pause(0.05)
% end