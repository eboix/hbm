<<<<<<< HEAD
n_vals = 20000;
d_vals = 0:0.2:2.4;
c_vals = 6:4:20;
[N,D,C] = meshgrid(n_vals,d_vals,c_vals);
for iter=1:length(N(:));
=======
function hbm_stats_parfor(iter)
    n_vals = 20000;
    d_vals = 0:0.2:2.4;
    c_vals = 6:4:20;
   [N,D,C] = meshgrid(n_vals,d_vals,c_vals);
>>>>>>> origin/master
    n = N(iter);
    d = D(iter);
    c = C(iter);
    hbm_stats('nbwalk',n,0,0,c,d,1,5,'res/')
end
