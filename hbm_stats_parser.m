METHOD_TO_TEST = 'nbwalk';
directory_name = sprintf('res/%s',METHOD_TO_TEST);
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
N_TO_TEST = 20000;
Trn = T((T.methodname == METHOD_TO_TEST) & (T.n == N_TO_TEST) & (T.t == 1),:);
drange = 0:0.1:4;
crange = 0:0.1:20;
imgres = cell(length(drange), length(crange));
imggiantn = cell(length(drange), length(crange));
di = 0;
for d = drange
    d
    di = di + 1;
    ci = 0;
    Trnd = Trn(abs(Trn.d - d) <= 0.0001,:);
    for c = crange
        % c
        % d
        ci = ci + 1;
        % I made a small mistake in nbwalk:
        currtab = Trnd(Trnd.c == c,:);
        if size(currtab,1) == 0
            imgres(di,ci) = {NaN};
            imggiantn(di,ci) = {NaN};
        else
            imgres(di,ci) = currtab.res;
            imggiantn(di,ci) = currtab.giant_n;
        end
    end
end

mvals = cellfun(@(x) sum(x)/length(x), imgres);
% FILL WITH APPROX DATA:
approxvals = mvals;
approx_iter = 0;
while(sum(sum(isnan(approxvals))) ~= 0)
    approx_iter = approx_iter + 1
    oldapproxvals = approxvals;
    for di = 1:length(drange)
        for ci = 1:length(crange)
            if isnan(approxvals(di,ci)) && di > 1
                approxvals(di,ci) = oldapproxvals(di-1,ci);
            end
            if isnan(approxvals(di,ci)) && di < length(drange)
                approxvals(di,ci) = oldapproxvals(di+1,ci);
            end
            if isnan(approxvals(di,ci)) && ci < length(crange)
                approxvals(di,ci) = oldapproxvals(di,ci+1);
            end
            if isnan(approxvals(di,ci)) && ci > 1
                approxvals(di,ci) = oldapproxvals(di,ci-1);
            end
        end
    end
end
% mvals = approxvals;
% mvals = cellfun(@(x,y) sum(x.*y/18000)/length(x), imgres,imggiantn);
% mvals = real(cellfun(@(x) x, imggiantn));
color_res = 1024;
colormap(jet(color_res));
disp('About to draw heatmap.')
heatmap(mvals,crange,drange,[],'NanColor', [1 1 1],'ColorBar',true,'MinColorValue',0.5,'MaxColorValue',1)
xlabel('c');
ylabel('d');
title(sprintf('GBM Giant Size, avg of 5 trials, n = %d', N_TO_TEST));
h = gcf;
set(h,'PaperOrientation','landscape');
pdfname = sprintf('manual_figs/%s_n%d.pdf',METHOD_TO_TEST,N_TO_TEST);
export_fig(pdfname,'-q101')
% print('-fillpage',pdfname,'-dpdf')