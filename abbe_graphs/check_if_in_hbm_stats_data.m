function [in_table,time_elapsed] = check_if_in_hbm_stats_data(hbm_stats_data,class_name,a,b,c,d,t,n)
    time_elapsed = -1;
    if height(hbm_stats_data) == 0
        in_table = 0;
        return
    end
    name_comp = strcmp(hbm_stats_data.class_name,class_name)';
    a_comp = [hbm_stats_data.a{:}] == a;
    b_comp = [hbm_stats_data.b{:}] == b;
    c_comp = [hbm_stats_data.c{:}] == c;
    d_comp = [hbm_stats_data.d{:}] == d;
    t_comp = [hbm_stats_data.t{:}] == t;
    n_comp = [hbm_stats_data.n{:}] == n;
    
    temptable = hbm_stats_data(name_comp & a_comp & b_comp & c_comp & d_comp & t_comp & n_comp,:);
    if height(temptable) == 0
        in_table = 0;
        return
    end
    in_table = 1;
    assert(height(temptable) == 1);
    time_elapsed = temptable.time_elapsed{1};
end