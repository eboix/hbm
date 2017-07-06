directory_name = 'res';
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

Trn = T((T.methodname == 'randwalk') & (T.n == 6000) & (T.t == 1),:);
drange = 0:0.1:2.5;
crange = 4:2:20;
di = 0;
for d = 0:0.1:2.5
    di = di + 1;
    ci = 0;
    for c = crange
      %  c
       % d
        ci = ci + 1;
        imgres(di,ci) = Trn(Trn.c == c & Trn.d == d,:).res;
    end
end

mvals = cellfun(@(x) sum(x)/length(x), imgres);
% mvals = real(cellfun(@(x) x, imgres));
color_res = 1024;
colormap(hot(color_res));
heatmap(mvals,crange,drange,'%0.2f','ColorBar',true,'MinColorValue',0.5,'MaxColorValue',1)
xlabel('c');
ylabel('d');
title('randwalk agreement, avg of 5 trials');