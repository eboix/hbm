function [labels,A,adj_list] = read_polblogs_graph(k)
assert(k == 2);
contents = csvread('realdata/polblogs/polblogs.txt');
n = contents(1,1);
m = contents(1,2);
labels = contents(2:(2+n-1),2) + 1;
adj_list = contents((2+n):end,:);
A = sparse(adj_list(:,1),adj_list(:,2),1,n,n);
A = triu(A);
A = A + A';

end