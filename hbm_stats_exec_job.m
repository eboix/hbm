function hbm_stats_exec_job(job_num)
n_vals = 20000;
d_vals = 0:0.05:4;
c_vals = 0:0.05:20;
[N,D,C] = meshgrid(n_vals,d_vals,c_vals);

if nargin == 0 || job_num == -1
    num_jobs = length(N(:));
    disp(sprintf('NUM_JOBS: %d', num_jobs));
    fi = fopen('NUM_JOBS','w+');
    fprintf(fi,'%d',num_jobs);
    fclose(fi);
    return
end

n = N(job_num);
d = D(job_num);
c = C(job_num);
if c > 8 && d < 1
    return
end
if c > 13 && d < 1.5
    return
end
if c > 17 && d < 2.5
    return
end
hbm_stats('giant_size',n,0,0,c,d,1,5,'res/')
end
