function hbm_stats_exec_job(job_num)

methodname = 'graph_pow_adj';
n_vals = [100 200 400 1000];
d_vals = 0:0.05:4;
c_vals = 5:0.05:20;
optional_param_vals = -1;
[N,D,C,O] = ndgrid(n_vals,d_vals,c_vals,optional_param_vals);

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

rescombined_names = {};
rescombined_tables = {};
loadedRescombined = table(rescombined_names,rescombined_tables);

for iter=begin_raw_job:end_raw_job
    if mod(iter,100) == 0
        iter
    end

    perm_iter = perm(iter);
    n = N(perm_iter);
    a = 0;
    b = 0;
    d = D(perm_iter);
    c = C(perm_iter);
    opt_param = O(perm_iter);
    
    % CHECK THAT WE HAVEN'T ALREADY CALCULATED THIS!
    directory_name = sprintf('res/%s/n%d',methodname,n)
    rescombined_name = combine_hbm_stats(directory_name,true);
    searchintable = loadedRescombined(strcmp(loadedRescombined.rescombined_names, rescombined_name),:);
    if height(searchintable) == 0
	disp('Not found. Loading');
        rescombined_names = {rescombined_name};
        if exist(rescombined_name,'file')
		load(rescombined_name);
        else
		T = table;
	end;
	rescombined_tables = {T};
        loadedRescombined = [loadedRescombined; table(rescombined_names, rescombined_tables)];
    end
    curr_T = loadedRescombined(strcmp(loadedRescombined.rescombined_names,rescombined_name),:);
    if height(curr_T) ~= 0
	curr_T = curr_T.rescombined_tables;
    	prior_obs = curr_T(curr_T.n == n,:);
    	prior_obs = prior_obs(strcmp(prior_obs.methodname,methodname),:);
    	prior_obs = prior_obs(abs(prior_obs.a - a) <= 0.0001,:);
   	prior_obs = prior_obs(abs(prior_obs.b - b) <= 0.0001,:);
    	prior_obs = prior_obs(abs(prior_obs.c - c) <= 0.0001,:);
    	prior_obs = prior_obs(abs(prior_obs.d - d) <= 0.0001,:);
    	prior_obs = prior_obs(abs(curr_T.optional_param - opt_param) <= 0.0001,:);
    	if height(prior_obs) ~= 0
        	continue
    	end
    end
    if (d-2)*10 > c
        continue
    end
    hbm_stats(methodname,n,a,b,c,d,1,1,directory_name,false,optional_param);

    
    
end
