dfs_stack{1} = 'res';
i = 1;
while i <= length(dfs_stack)
    curr_dir = dfs_stack{i};
    dir_obj = dir(curr_dir);
    for l = 1:length(dir_obj)
        if dir_obj(l).isdir && ~strcmp(dir_obj(l).name,'.') && ~strcmp(dir_obj(l).name,'..')
            j = length(dfs_stack);
            dfs_stack{j+1} = fullfile(curr_dir,dir_obj(l).name);
        end
    end
    i = i + 1;
end

for i = 1:length(dfs_stack)
    curr_dir = dfs_stack{i};
    dir_obj = dir(curr_dir);
    
    hasfiles = any(~dir_obj.isdir);
    if ~hasfiles
        continue
    end
    
    mindate = min(dir_obj.datenum);
    rescombined_file = combine_hbm_stats(curr_dir,true);
    rescombineddate = dir(rescombined_file).datenum;
    if rescombineddate < mindate % UPDATE.
        disp(['Updating ' rescombined_file]);
        combine_hbm_stats(curr_dir);
    end
end