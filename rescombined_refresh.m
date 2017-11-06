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
disp('Read directories');

for i = 1:length(dfs_stack)
    curr_dir = dfs_stack{i};
    dir_obj = dir(curr_dir);
    
    hasfiles = any(~[dir_obj(:).isdir]);
    if ~hasfiles
        continue
    end
    
    maxdate = max([dir_obj(:).datenum]);
    rescombined_file = combine_hbm_stats(curr_dir,true);
    update_file = true;
    
%     if exist(rescombined_file,'file')
%         update_file = true;
%     else
%         rescombined_dir = dir(rescombined_file);
%         rescombined_date = rescombined_dir.datenum;
%         if rescombined_date < maxdate % UPDATE.
%             update_file = true;
%         end
%     end

    if update_file
        disp(['Updating ' rescombined_file]);
        combine_hbm_stats(curr_dir);
    end
end