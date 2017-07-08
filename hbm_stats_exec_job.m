function hbm_stats_exec_job(job_num)

methodname = 'adj';
n_vals = 10000;
d_vals = 0:0.1:4;
c_vals = 5:0.1:20;
[N,D,C] = meshgrid(n_vals,d_vals,c_vals);

raw_num_jobs = length(N(:));
DESIRED_MAX_NUM_JOBS = 100;

if DESIRED_MAX_NUM_JOBS > raw_num_jobs
    DESIRED_MAX_NUM_JOBS = raw_num_jobs;
end

if nargin == 0 || job_num == -1
    num_jobs = DESIRED_MAX_NUM_JOBS + 1;
    disp(sprintf('NUM_JOBS: %d', num_jobs));
    fi = fopen('NUM_JOBS','w+');
    fprintf(fi,'%d',num_jobs);
    fclose(fi);
    return
end

raw_jobs_per_task = floor(raw_num_jobs/DESIRED_MAX_NUM_JOBS);
begin_raw_job = raw_jobs_per_task*(job_num-1)+1;
end_raw_job = min(raw_num_jobs,begin_raw_job+raw_jobs_per_task-1);

if job_num == -2
    begin_raw_job = 1;
    end_raw_job = raw_num_jobs;
end


rng default; % So that the partition is standardized.
[~,perm] = sort(rand(1,raw_num_jobs));

rng('shuffle'); % Restore "true" randomness.

for iter=begin_raw_job:end_raw_job
    if mod(iter,10) == 0
        iter
    end
    perm_iter = perm(iter);
    n = N(perm_iter);
    d = D(perm_iter);
    c = C(perm_iter);
    
    hbm_stats(methodname,n,0,0,c,d,1,1,sprintf('res/%s/',methodname),false);
end
