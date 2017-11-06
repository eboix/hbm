function [in_table,time_elapsed] = check_if_in_gbm_stats_data(gbm_stats_data,class_name,cc,dd,nn)
    time_elapsed = -1;
    if height(gbm_stats_data) == 0
        in_table = 0;
        return
    end
    name_comp = strcmp(gbm_stats_data.class_name,class_name)';
    rowc = [gbm_stats_data.thresh_c{:}];
    a_comp = (rowc == cc);
    rowd = [gbm_stats_data.center_dist{:}];
    b_comp = (rowd == dd);
    rown = [gbm_stats_data.n{:}];
    n_comp = (rown == nn);
    temptable = gbm_stats_data(name_comp & a_comp & b_comp & n_comp,:);
    if height(temptable) == 0
        in_table = 0;
        return
    end
    in_table = 1;
    time_elapsed = temptable.time_elapsed{1};
end