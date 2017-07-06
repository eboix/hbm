n_vals = 2000:2000:2000;
d_vals = 0:0.2:0.2;
[N,D] = meshgrid(n_vals,d_vals);
parfor iter=1:length(N);
    n = N(iter);
    d = D(iter);
    for c = 2:10
        hbm_stats('adj',n,0,0,c*2,d,1,10)
    end
end