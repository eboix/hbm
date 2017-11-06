function [in_table,time_elapsed] = check_if_in_sbm_stats_data(sbm_stats_data,class_name,aa,bb,nn)
    time_elapsed = -1;
    if height(sbm_stats_data) == 0
        in_table = 0;
        return
    end
    name_comp = strcmp(sbm_stats_data.class_name,class_name)';
    rowa = [sbm_stats_data.a{:}];
    a_comp = (rowa == aa);
    rowb = [sbm_stats_data.b{:}];
    b_comp = (rowb == bb);
    rown = [sbm_stats_data.n{:}];
    n_comp = (rown == nn);
    temptable = sbm_stats_data(name_comp & a_comp & b_comp & n_comp,:);
    if height(temptable) == 0
        in_table = 0;
        return
    end
    in_table = 1;
    time_elapsed = temptable.time_elapsed{1};
end