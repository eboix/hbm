function out_file_name = combine_hbm_stats(directory_name,just_tell_me_out_file_name)

out_file_name = sprintf('rescombined/%s.mat',strrep(directory_name,'/','_'));
out_file_name = strrep(out_file_name,'\','_');

if nargin == 1 || ~just_tell_me_out_file_name
    
    if exist(out_file_name,'file')
        load(out_file_name);
        oldtable = round_doubles(T);
    end
    
    % Tabulate files in directory.
    files = dir(directory_name);
    file_index = find(~[files.isdir]);
    num_files = length(file_index);
    
    MethodName = cell(num_files,1);
    Res = cell(num_files,1);
    N = zeros(num_files,1);
    A = zeros(num_files,1);
    B = zeros(num_files,1);
    C = zeros(num_files,1);
    dval = zeros(num_files,1);
    tvals = zeros(num_files,1);
    Dval = cell(num_files,1);
    GiantNs = cell(num_files,1);
    Opt_Param = -ones(num_files,1);
    use_kmeans = -ones(num_files,1);
    for i = 1:num_files;
        if mod(i,100) == 0
            i
        end
        file_name = files(file_index(i)).name;
        load(sprintf('%s/%s', directory_name, file_name));
        MethodName{i} = methodname;
        Res{i} = res;
        N(i) = n;
        A(i) = a;
        B(i) = b;
        C(i) = c;
        dval(i) = d;
        tvals(i) = t;
        Dval{i} = D;
        GiantNs{i} = giant_ns;
        if exist('optional_param','var')
            Opt_Param(i) = optional_param;
        end
        if exist('USE_KMEANS','var')
            use_kmeans(i) = USE_KMEANS;
        end
    end
    methodname = categorical(MethodName);
    res = Res;
    n = N;
    a = A;
    b = B;
    c = C;
    d = dval;
    t = tvals;
    D = Dval;
    giant_n = GiantNs;
    optional_param = Opt_Param;
    
    T = table(methodname,res,n,a,b,c,d,t,D,giant_n,optional_param,use_kmeans);
    T = round_doubles(T);
    
    % Combine new table and old table.
    if exist('oldtable','var')
        T = concat_tables(oldtable,T);
    end
    
    if ~exist('rescombined','dir')
        mkdir('rescombined')
    end
    save(out_file_name,'T');
    
    if isunix || ismac
        system(sprintf('rm %s/*.mat',directory_name));
    elseif ispc
        system(sprintf('del %s\\*.mat',directory_name));
    end
end
end

function Tout = round_doubles(Tin)
        % Merge observations with same parameters within tolerance.
        doubleparams = {'a','b','c','d','t','optional_param'};
        Tout = Tin;
        Tout(:,doubleparams) = array2table(round(table2array(Tin(:,doubleparams)),10));
end

function T = concat_tables(oldtable,T)
    params = {'methodname','n','a','b','c','d','t','optional_param','USE_KMEANS'};
    subsT = T(:,params);
    subsoldT = oldtable(:,params);
    [~,ia,ib] = union(subsT,subsoldT,'rows');
    T = [T(ia,:); oldtable(ib,:)];
end
