function hbm_stats_exec_job(job_num)

global USE_KMEANS;

USE_KMEANS = true; % Only supported by nb_classifier.
methodname = 'graph_pow_adj_trunc';
n_vals = [20000];
a_vals = 2:0.05:3;
b_vals = 0:0.05:1;
c_vals = [1];
d_vals = 0;
t_vals = [0 0.05 0.1 0.5];
optional_param_vals = [1 2];

[NV,AV,BV,CV,DV,TV,OV] = ndgrid(n_vals,a_vals,b_vals,c_vals,d_vals,t_vals,optional_param_vals);

raw_num_jobs = length(NV(:));
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
    n = NV(perm_iter);
    a = AV(perm_iter);
    b = BV(perm_iter);
    c = CV(perm_iter);
    d = DV(perm_iter);
    t = TV(perm_iter);
    opt_param = OV(perm_iter);
    
    if t == 1 && (d-2)*10 > c
        continue
    end
    
    if t == 0 && a < b
        continue
    end
    
    % CHECK THAT WE HAVEN'T ALREADY CALCULATED THIS!
    directory_name = sprintf('res/%s/n%d',methodname,n);
    rescombined_name = combine_hbm_stats(directory_name,true);
    searchintable = loadedRescombined(strcmp(loadedRescombined.rescombined_names, rescombined_name),:);
    if height(searchintable) == 0
        directory_name
        disp('Not found. Loading');
        rescombined_names = {rescombined_name};
        if exist(rescombined_name,'file')
            load(rescombined_name);
            keys = cell(1,height(T));
            tic;
            for row = 1:height(T)
                if mod(row,1000)==0
                    row
                end
                keys{row} = get_key(T.methodname(row),T.n(row),T.a(row),T.b(row),T.c(row),T.d(row),T.t(row),T.optional_param(row));
            end
            toc;
            
%                         tic;
%             keys = arrayfun(@(row) get_key(T.methodname(row),T.n(row),T.a(row),T.b(row),T.c(row),T.d(row),T.t(row),T.optional_param(row)),1:height(T),'UniformOutput',false);
%             toc;
        else
            keys = {'empty'};
        end
        rescombined_tables = {containers.Map(keys,ones(1,length(keys)))};
        loadedRescombined = [loadedRescombined; table(rescombined_names, rescombined_tables)];
    end
    curr_T = loadedRescombined(strcmp(loadedRescombined.rescombined_names,rescombined_name),:).rescombined_tables{1};
    if isKey(curr_T,get_key(methodname,n,a,b,c,d,t,opt_param))
        continue
    end

    hbm_stats(methodname,n,a,b,c,d,t,1,directory_name,false,opt_param);
    
end
end

function key_val = get_key(mname,n,a,b,c,d,t,opt_param)
key_val = sprintf('%s_%d_%0.2f_%0.2f_%0.2f_%0.2f_%0.2f_%0.2f', mname,n,a,b,c,d,t,opt_param);
end
