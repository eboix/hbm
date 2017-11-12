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
%      {@pow_adj_classifier, 'pow (adj) none 0','no_clean',true,'pow_c',0},... 
%      {@pow_adj_classifier, 'pow (adj) none 0.15','no_clean',true,'pow_c',0.15},... 
%      {@pow_adj_classifier, 'pow (adj) none 0.3','no_clean',true,'pow_c',0.3}, ...
%      {@pow_adj_classifier, 'pow (adj) none 0.5','no_clean',true,'pow_c',0.5}, ...
     % {@pow_adj_classifier, 'pow (adj) none 1','no_clean',true,'pow_c',1}, ...
     % {@pow_adj_classifier, 'pow (adj) none 2','no_clean',true,'pow_c',2}, ...
      ...
     % {@pow_lap_classifier, 'pow (lap) none 0', 'no_clean',true,'pow_c',0},... 
     % {@pow_lap_classifier, 'pow (lap) none 0.15','no_clean',true,'pow_c',0.15},... 
     % {@pow_lap_classifier, 'pow (lap) none 0.3','no_clean',true,'pow_c',0.3}, ...
     % {@pow_lap_classifier, 'pow (lap) none 0.5','no_clean',true,'pow_c',0.5}, ...
     % {@pow_lap_classifier, 'pow (lap) none 1','no_clean',true,'pow_c',1}, ...
     % {@pow_lap_classifier, 'pow (lap) none 2','no_clean',true,'pow_c',2}, ...
%      ...
%      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 0.15', 'clean_c',2,'pow_c',0.15},... 
%      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 0.3','clean_c',2,'pow_c',0.3}, ...
%      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
%      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 1','clean_c',2,'pow_c',1}, ...
%      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 2','clean_c',2,'pow_c',2}, ...
%      ...
%      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 0.15', 'clean_c',2,'pow_c',0.15},... 
%      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 0.3','clean_c',2,'pow_c',0.3}, ...
%      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
%      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 1','clean_c',2,'pow_c',1}, ...
%      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 2','clean_c',2,'pow_c',2}, ...
%      ...
%      {@pow_nb_classifier, 'graphpow (nb) 2 0.15', 'clean_c',2,'pow_c',0.15},... 
%      {@pow_nb_classifier, 'graphpow (nb) 2 0.3','clean_c',2,'pow_c',0.3}, ...
%      {@pow_nb_classifier, 'graphpow (nb) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
%      {@pow_nb_classifier, 'graphpow (nb) 2 1','clean_c',2,'pow_c',1}, ...
%      {@pow_nb_classifier, 'graphpow (nb) 2 2','clean_c',2,'pow_c',2}, ...
%      {@pow_lap_classifier, 'lap (no clean)', 'no_clean',true,'pow_c',0},... 
%      {@pow_lap_classifier, 'lap (clean 1)','clean_c',1,'pow_c',0},... 
%      {@pow_lap_classifier, 'lap (clean 2)','clean_c',2,'pow_c',0},... 
%      {@pow_lap_classifier, 'lap (clean 3)','clean_c',3,'pow_c',0},...
%      ...
      {@pow_nb_classifier, 'nb (no clean)', 'no_clean',true,'pow_c',0},... 
      {@pow_nb_classifier, 'nb (clean 1)','clean_c',1,'pow_c',0},... 
%      {@pow_nb_classifier, 'nb (clean 2)','clean_c',2,'pow_c',0},... 
%      {@pow_nb_classifier, 'nb (clean 3)','clean_c',3,'pow_c',0},...
     ...
%      {@pow_sym_norm_lap_classifier, 'normlap (no clean)', 'no_clean',true,'pow_c',0},... 
%     {@pow_sym_norm_lap_classifier, 'normlap (clean 1)','clean_c',1,'pow_c',0},... 
%      {@pow_sym_norm_lap_classifier, 'normlap (clean 2)','clean_c',2,'pow_c',0},... 
%      {@pow_sym_norm_lap_classifier, 'normlap (clean 3)','clean_c',3,'pow_c',0},... 
  };

n_vals = [100:100:1000 2000:1000:10000 20000:10000:100000 200000];
num_trials = 50;

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
