function [labels,A] = read_polblogs_graph(k)

contents = csvread('realdata/twitter/twitter.txt');
n = contents(1,1);
m = contents(1,2);
labels = contents(2:(2+n-1),2);

if k == 3
left = (labels < -15);
right = (labels > 15);
mid = ~left & ~right;
labels(left) = 1;
labels(right) = 2;
labels(mid) = 3;
elseif k == 2
left = (labels < 0);
right = (labels >= 0);
labels(left) = 1;
labels(right) = 2;
else
    assert(false);
end

adj_list = contents((2+n):end,:);
A = sparse(adj_list(:,1),adj_list(:,2),1,n,n);
A = triu(A);
A = A + A';

end