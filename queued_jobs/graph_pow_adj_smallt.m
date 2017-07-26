%%%%%%%% HBM_STATS_EXEC_JOB options.
% Only supported by nbwalk, graph_pow_lap, graph_pow_adj, graph_pow_adj_trunc.
global USE_KMEANS;
USE_KMEANS = true;

methodname = 'graph_pow_adj';
n_vals = [20000];
a_vals = 2:0.05:3;
b_vals = 0:0.05:1;
c_vals = 2;
d_vals = 0;
t_vals = [0 0.05 0.1 0.2 0.5];
optional_param_vals = [1 2 3];

%%%%%%%%%% HBM_STATS_PARSER options.
ABPLOT=true;

