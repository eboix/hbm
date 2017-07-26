function [class,V,D] = adj_classifier(obj,giant_A,giant_rev)
% obj is a hybrid_block_model object.
% Optional giant_A and giant_rev arguments.
% Use second eigval of A to split vertices.
% TODO DOES NOT DEPEND ON obj.k.

assert(nargin == 1 || nargin == 3);

%   disp('Running adj_classifier');
if nargin == 1
    [giant_A,~,giant_rev,~,~] = get_giant_adj_matrix(obj);
end
n = obj.n;
giant_n = length(giant_A);
[V,D] = eigs(giant_A,2);

classeigvec = V(:,2);
global USE_KMEANS
if USE_KMEANS
    C = kmeans(classeigvec,obj.k,'replicates',10);
    class = zeros(n,1);
    class(giant_rev(C == 1)) = 1;
    class(giant_rev(C == 2)) = 2;
    if obj.center(1) < -2.5
        disp('pause')
    end
else
    [~,idx] = sort(classeigvec);
    class = zeros(n,1);
    class(giant_rev(idx(1:floor(giant_n/2)))) = 1;
    class(giant_rev(idx(floor(giant_n/2):end))) = 2;
end

end
