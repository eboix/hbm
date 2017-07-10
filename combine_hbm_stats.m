function out_file_name = combine_hbm_stats(directory_name,just_tell_me_out_file_name)

out_file_name = sprintf('rescombined/%s.mat',strrep(directory_name,'/','_'));

if nargin == 1 || ~just_tell_me_out_file_name
    
    if exist(out_file_name,'file')
        load(out_file_name);
        oldtable = preprocess_T(T);
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
    
    T = table(methodname,res,n,a,b,c,d,t,D,giant_n,optional_param);
    T = preprocess_T(T);
    
    % Combine new table and old table.
    if exist('oldtable','var')
        params = {'methodname','n','a','b','c','d','t','optional_param'};
        subsT = T(:,params);
        subsoldT = oldtable(:,params);
        [~,ia,ib] = union(subsT,subsoldT,'rows');
        T = [T(ia,:); oldtable(ib,:)];
    end
    
    if ~exist('rescombined','dir')
        mkdir('rescombined')
    end
    save(out_file_name,'T');
    
    for i = 1:num_files
        file_name = files(file_index(i)).name;
        fullname = sprintf('%s/%s', directory_name, file_name);
        delete fullname
    end
end
end

function Tout = preprocess_T(Tin)
        % Merge observations with same parameters within tolerance.
        doubleparams = {'a','b','c','d','t','optional_param'};
        [~,ia] = uniquetol(table2array(Tin(:,doubleparams)),1e-10,'ByRows',true);
        Tout = Tin(ia,:);
end
