function class = optimal_gbm_classifier(obj)
% obj is a gbm object. Cuts giant component into two clusters based on
% positions.

assert(obj.k == 2);
assert(all(obj.prob_dist == [1 1]));

dists = zeros(obj.n,2);

for i = 1:obj.n
   for j = 1:2
       dists(i,j) = norm(obj.pos(i,:) - obj.center(j,:));
   end
end

[~,giant_mask,~] = obj.get_giant_adj_matrix();

class = zeros(obj.n,1);
class(dists(:,1) > dists(:,2)) = 1;
class(dists(:,1) < dists(:,2)) = 2;
class(~giant_mask) = 0;

end
