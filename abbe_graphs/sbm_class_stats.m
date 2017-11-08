import block_model.classifiers.*;

try
load('sbm_stats_data.mat');
catch
    warning('COULD NOT FIND SBM_STATS_DATA.mat. OVERWRITING.');
end

classifiers = ...
    {
  %  {@nb_classifier, 'nb'}, ...
  %  {@adj_classifier, 'adj'}, ...
  %  {@lap_classifier, 'lap'}, ...
  %  {@sdp_classifier, 'sdp'}, ...
  %  {@sym_norm_lap_classifier, 'normlap'}, ...
     {@pow_adj_classifier, 'graphpow (adj) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
     {@pow_adj_classifier, 'graphpow (adj) 2 1','clean_c',2,'pow_c',1}, ...
     {@pow_adj_classifier, 'graphpow (adj) 2 2','clean_c',2,'pow_c',2}, ...
  };

n_vals = [100:100:1000 2000:1000:10000 20000:10000:100000 200000];
num_trials = 100;

if ~exist('sbm_stats_data', 'var')
    sbm_stats_data = table({},{},{},{},{},{});
    sbm_stats_data.Properties.VariableNames = {'class_name', 'a', 'b', 'n', 'giant_agreement','time_elapsed'};
end

for TIMEOUT = 1:200

for a = 2.01:0.5:4.01
b = -sqrt(4*a + 1) + a + 1;
a = a - 0.01; % Go slightly below KS threshold, so recovery is possible at large n.

for classi = 1:length(classifiers)
    class_cell = classifiers{classi};
    class_func = class_cell{1};
    class_name = class_cell{2}
    class_vals = ones(length(n_vals),num_trials)*nan;

    for ni = 1:length(n_vals)
        n = n_vals(ni);
        [in_table,time_elapsed] = check_if_in_sbm_stats_data(sbm_stats_data,class_name,a,b,n);
        if in_table
            if time_elapsed > TIMEOUT
                break;
            end
            continue;
        end
        n
        tic
        try
            agreements = agree_vals_sbm(class_func,a,b,n,num_trials,class_cell{3:end});
         catch err
             disp(err)
             warning(['Error in ' class_name 'code']);
             
            time_elapsed = toc;
            if time_elapsed > TIMEOUT
             break
            end
            continue
         end
        time_elapsed = toc;
        
        temptable = table({class_name},a,b,n,agreements,time_elapsed);
        temptable.Properties.VariableNames = sbm_stats_data.Properties.VariableNames;
        sbm_stats_data = [sbm_stats_data;temptable]; %#ok<AGROW>
        
        save_stats_file = 'sbm_stats_data.mat';
        if exist(save_stats_file,'file')
            delete(save_stats_file);
        end
        save(save_stats_file,'sbm_stats_data');
        if time_elapsed > TIMEOUT
            break
        end
        
    end
    
end
end
end