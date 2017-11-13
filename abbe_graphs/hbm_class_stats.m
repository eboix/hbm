import block_model.classifiers.*;

try
load('hbm_stats_data.mat');
catch
    warning('COULD NOT FIND HBM_STATS_DATA.mat. OVERWRITING.');
end

classifiers = {...
            {@pow_adj_classifier, 'adj (clean 1)','clean_c',1,'pow_c',0}, ...
            {@pow_lap_classifier, 'lap (clean 1)','clean_c',1,'pow_c',0},...
            {@pow_randwalk_classifier, 'randwalk (clean 1) (pow 0)', 'clean_c',1,'pow_c',0},...
            {@pow_nb_classifier, 'nb (clean 1)','clean_c',1,'pow_c',0}, ...
            {@pow_randwalk_classifier, 'randwalk (clean 1) (pow 0.15)', 'clean_c',1,'pow_c',0.15},...
            {@optimal_gbm_classifier, 'best possible'}
            {@pow_randwalk_classifier, 'randwalk (clean 1) (pow 0.3)','clean_c',1,'pow_c',0.3}, ...
            {@pow_randwalk_classifier, 'randwalk (clean 1) (pow 0.5)', 'clean_c',1,'pow_c',0.5}, ...
            };

% classifiers = ...
%     {
%     {@pow_sym_norm_adj_classifier, 'normadj (1 clean, pow 0.15)','clean_c',1,'pow_c',0.15},...
%     {@pow_sym_norm_adj_classifier, 'normadj (1 clean, pow 0.3)','clean_c',1,'pow_c',0.3},...
%     {@nb_classifier, 'nb'}, ...
%     {@adj_classifier, 'adj'}, ...
%     {@lap_classifier, 'lap'}, ...
%     {@sym_norm_lap_classifier, 'normlap'}, ...
%     {@pow_sym_norm_lap_classifier, 'normlap (clean 1)','clean_c',1,'pow_c',0},...
% };

a = 2.51;
b = -sqrt(4*a + 1) + a + 1;
a = a - 0.01; % Go slightly below KS threshold, so recovery is possible at large n.

a_vals = {a};
b_vals = {b};
c_vals = {10};
d_vals = {1};
t_vals = {0.5};
n_vals = num2cell([100:200:1000 2000:2000:10000 20000:20000:100000 200000]);
num_trials = 50;

model_params = allcomb(classifiers, a_vals, b_vals, c_vals, d_vals, t_vals, n_vals); % Important that n should be last....
model_params = cell2table(model_params);
model_params.Properties.VariableNames = {'class_cell', 'a', 'b', 'c', 'd', 't', 'n'};

if ~exist('hbm_stats_data', 'var')
    hbm_stats_data = table({},{},{},{},{},{},{},{},{});
    hbm_stats_data.Properties.VariableNames = {'class_name', 'a', 'b', 'c', 'd', 't', 'n', 'giant_agreement','time_elapsed'};
end

for TIMEOUT = 1:200
    timeout = false;
    for ii = 1:height(model_params)

        class_cell = model_params.class_cell{ii};
        a = model_params.a(ii);
        b = model_params.b(ii);
        c = model_params.c(ii);
        d = model_params.d(ii);
        t = model_params.t(ii);
        n = model_params.n(ii);
        
        % So we don't recalculate stuff.
        if t == 0
           c = 0;
           d = 0;
        elseif t == 1
            a = 0;
            b = 0;
        end
        
        if ii > 1
            old_class_name = class_name;
        end
        class_func = class_cell{1};
        class_name = class_cell{2}
        if ii > 1 && timeout
            if strcmp(old_class_name,class_name)
                continue;
            else
                timeout = false;
            end
        end

        [in_table,time_elapsed] = check_if_in_hbm_stats_data(hbm_stats_data,class_name,a,b,c,d,t,n);
        if in_table
            if time_elapsed > TIMEOUT
                timeout = true;
                continue;
            end
            continue;
        end
        
        n
        tic
        try
            agreements = agree_vals_hbm(class_func,a,b,c,d,t,n,num_trials,class_cell{3:end});
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
        
        temptable = table({class_name},a,b,c,d,t,n,agreements,time_elapsed);
        temptable.Properties.VariableNames = hbm_stats_data.Properties.VariableNames;
        hbm_stats_data = [hbm_stats_data;temptable]; %#ok<AGROW>
        
        save_stats_file = 'hbm_stats_data.mat';
        if exist(save_stats_file,'file')
            delete(save_stats_file);
        end
        save(save_stats_file,'hbm_stats_data');
        if time_elapsed > TIMEOUT
            break
        end
        
    end
    
end
