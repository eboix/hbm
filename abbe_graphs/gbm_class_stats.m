import block_model.classifiers.*;

% graphpowtemp_adj = @(x) pow_adj_classifier(x,'clean_c',2, 'pow_c',0.15);

classifiers = ...
    {{@nb_classifier, 'nb'}, ...
    {@adj_classifier, 'adj'}, ...
    {@lap_classifier, 'lap'}, ...
    {@sdp_classifier, 'sdp'}, ...
    {@sym_norm_lap_classifier, 'normlap'}, ...
    {@pow_adj_classifier, 'graphpow (adj)'}, ...
    {@optimal_gbm_classifier, 'best possible'}};

n_vals = [100:200:1000 2000:2000:10000 20000:20000:100000 200000];
num_trials = 25;

if ~exist('gbm_stats_data', 'var')
    gbm_stats_data = table({},{},{},{},{},{});
    gbm_stats_data.Properties.VariableNames = {'class_name', 'thresh_c', 'center_dist', 'n', 'giant_agreement','time_elapsed'};
end

for TIMEOUT = 1:200
    
    for c = 10
        for d = 1:1:3
            for classi = 1:length(classifiers)
                class_cell = classifiers{classi};
                class_func = class_cell{1};
                class_name = class_cell{2}
                class_vals = ones(length(n_vals),num_trials)*nan;
                
                for ni = 1:length(n_vals)
                    n = n_vals(ni);
                    [in_table,time_elapsed] = check_if_in_gbm_stats_data(gbm_stats_data,class_name,c,d,n);
                    if in_table
                        if time_elapsed > TIMEOUT
                            break;
                        end
                        continue;
                    end
                    n
                    tic
                    try
                        agreements = agree_vals_gbm(class_func,c,d,n,num_trials);
                    catch err
                        disp(err)
                        warning(['Error in ' class_name 'code']);
                        
                        time_elapsed = toc;
                        if time_elapsed > TIMEOUT, break; end
                        continue
                    end
                    time_elapsed = toc;
                    
                    temptable = table({class_name},c,d,n,agreements,time_elapsed);
                    temptable.Properties.VariableNames = gbm_stats_data.Properties.VariableNames;
                    gbm_stats_data = [gbm_stats_data;temptable]; %#ok<AGROW>
                    
                    save_stats_file = 'gbm_stats_data.mat';
                    if exist(save_stats_file,'file')
                        delete(save_stats_file);
                    end
                    save(save_stats_file,'gbm_stats_data');
                    if time_elapsed > TIMEOUT
                        break
                    end
                    
                end
                
            end
        end
    end
end