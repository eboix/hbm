directory_name = 'res_adroit/adj';
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
row_names = cell(num_files,1);
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
METHOD_TO_TEST = 'adj';
N_TO_TEST = 20000;
Trn = T((T.methodname == METHOD_TO_TEST) & (T.n == N_TO_TEST) & (T.t == 1),:);
drange = 0:0.1:2.4;
crange = 6:1:20;
di = 0;
for d = drange
    di = di + 1;
    ci = 0;
    for c = crange
      %  c
       % d
        ci = ci + 1;
%        imgres(di,ci) = Trn(Trn.c == c & abs(Trn.d - d) <= 0.0001,:).res;
% I made a small mistake in nbwalk:
        imgres(di,ci) = Trn(Trn.c == c & abs(Trn.d - d) <= 0.0001,:).res;
        imggiantn(di,ci) = Trn(Trn.c == c & abs(Trn.d - d) <= 0.0001,:).giant_n;
    end
end

mvals = cellfun(@(x) sum(x)/length(x), imggiantn);
% mvals = cellfun(@(x,y) sum(x.*y/18000)/length(x), imgres,imggiantn);
% mvals = real(cellfun(@(x) x, imggiantn));
color_res = 1024;
colormap(hot(color_res));
heatmap(mvals,crange,drange,'%0.2f','ColorBar',true,'MinColorValue',0,'MaxColorValue',N_TO_TEST)
xlabel('c');
ylabel('d');
title(sprintf('%s agreement, avg of 5 trials, n = %d',METHOD_TO_TEST, N_TO_TEST));