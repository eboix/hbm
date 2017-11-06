n_vals = 10000:10000:100000;
d = 2;
c = 15;
t = 1;
Q = 0;
expected_tot_deg = zeros(1,length(n_vals));
exp_edge_left_to_right = zeros(1,length(n_vals));
actual_lr_edge = zeros(1,length(n_vals));
exp_h = zeros(1,length(n_vals));
res = zeros(1,length(n_vals));
lambda_2 = zeros(1,length(n_vals));
for i = 1:length(n_vals)
n = n_vals(i);
thresh = c/sqrt(n);

obj = hybrid_block_model(n, [1 1], t, [-d 0; d 0], thresh, Q);
expected_tot_deg(i) = (n*c^2 / 8) *(1 + exp(-d^2))
exp_edge_left_to_right(i) = sqrt(pi)/(6 * pi^2) * exp(-d^2) * c^3 * sqrt(n);
exp_h(i) = 2 * exp_edge_left_to_right(i) / expected_tot_deg(i)
A = obj.get_adj_matrix();

lpoints = find(obj.pos(:,1) < 0);
rpoints = find(obj.pos(:,1) >= 0);
actual_lr_edge(i) = full(sum(sum(A(lpoints,rpoints))));

res(i) = sum(sum(A))
[giant_A,~,giant_rev,~] = obj.get_giant_adj_matrix(A);
[class,V,D] = randwalk_classifier(obj,giant_A,giant_rev);
D = diag(sort(diag(D), 'descend'));
lambda_2(i) = D(2,2);
end