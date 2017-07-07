function hbm_stats_exec_job(job_num)

DESIRED_MAX_NUM_JOBS = 100;

methodname = 'giant_size';
n_vals = 20000;
d_vals = 0:0.1:4;
c_vals = 0:0.5:20;
[N,D,C] = meshgrid(n_vals,d_vals,c_vals);

raw_num_jobs = length(N(:));
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

for iter=begin_raw_job:end_raw_job
    n = N(iter);
    d = D(iter);
    c = C(iter);
    if c < 5 || abs(c*0.0592 + 1.7 - d) > 0.3
        continue
    end
%     if c > 8 && d < 1
%         continue
%     end
%     if c > 13 && d < 1.5
%         continue
%     end
%     if c > 17 && d < 2.5
%         continue
%     end
%     if d > 2.95
%         continue
%     end
%     if d < 2.05
%         continue
%     end
%     if  c < 7.45
%         continue
%     end
%     if c > 8
%         continue
%     end
    
    hbm_stats(methodname,n,0,0,c,d,1,5,sprintf('res/%s/',methodname),false)
end
