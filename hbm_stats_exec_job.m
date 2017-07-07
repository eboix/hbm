function hbm_stats_exec_job(job_num)
n_vals = 20000;
d_vals = 0:0.2:2.4;
c_vals = 6:2:20;
[N,D,C] = meshgrid(n_vals,d_vals,c_vals);

if job_num == -1
    command=strcat('export EBOIX_NUM_JOBS=',int2str(length(N(:))));
    disp(command);
    system(command);
    return
end

n = N(job_num);
d = D(job_num);
c = C(job_num);
hbm_stats('nbwalk',n,0,0,c,d,1,5,'res/')
end
