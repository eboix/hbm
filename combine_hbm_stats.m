function out_file_name = combine_hbm_stats(directory_name,justOutputName)

out_file_name = sprintf('rescombined/%s.mat',strrep(directory_name,'/','_'));

if nargin == 1 || ~justOutputName
    
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
    T = zeros(num_files,1);
    Dval = cell(num_files,1);
    GiantNs = cell(num_files,1);
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
        T(i) = t;
        Dval{i} = D;
        GiantNs{i} = giant_ns;
    end
    methodname = categorical(MethodName);
    res = Res;
    n = N;
    a = A;
    b = B;
    c = C;
    d = dval;
    t = T;
    D = Dval;
    giant_n = GiantNs;
    T = table(methodname,res,n,a,b,c,d,t,D,giant_n);
    
    if ~exist('rescombined','dir')
        mkdir('rescombined')
    end
    save(out_file_name,'T');
end
end