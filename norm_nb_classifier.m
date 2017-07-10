function class=norm_nb_classifier(obj,giant_mask)
% CODE MODIFIED FROM COLIN SANDON'S THESIS.
% obj is a hybrid_block_model object.
%Attempts to divide a graph’s vertices into clusters by using the dominant
%eigenvectors of the graph’s NORMALIZED nonbacktracking walk matrix.
%This function outputs a list of length n that lists a number from 0 to k
%for each vertex. 1 to k are the communities, while vertices that are
%outside the main component get an entry of 0 in the output.
%Computes the graph’s nonbacktracking walk matrix.

disp('Running norm_nb_classifier');
tic
if nargin == 1
    [~,giant_mask,~,~,~] = obj.get_giant_adj_matrix;
end
k = obj.k;
n = obj.n;
G = obj.adj_list;
% Filter out non-giant vertices.
G = G(giant_mask(G(:,1)) & giant_mask(G(:,2)),:);
[e,~] = size(G);

% Vectorize for efficiency.
Gt = G'; % transpose
I1vec = [1:2*e; Gt(1:end)]; % read in column major order
I1 = sparse(I1vec(1,:),I1vec(2,:),1,2*e,n);

Gt = [G(:,2) G(:,1)]; % swap columns
Gt = Gt'; % transpose
I2vec = [1:2*e; Gt(1:end)]; % read in column major order
I2 = sparse(I2vec(1,:),I2vec(2,:),1,2*e,n);

% Non-backtracking walks matrix.
B=I2*I1';
matrix_side = 2*e;
B(2:(2*matrix_side+2):end) = 0;
B((1+matrix_side):(2*matrix_side+2):end) = 0;
% Normalized non-backtracking walks matrix.
deg = sum(B,1);
degi = 1./deg;
norm_B = spdiags(degi',0,matrix_side,matrix_side) * B;
matrix_side
toc
%Finds the top k eigenvectors of the graph, or as many as it can if that is
%less than k.
flag=1;
maxV=k+1;
opts.isreal = 1;
opts.issym = 1;
opts.tol = 1e-10;
while flag>0
    maxV=maxV-1;
    [V,D,flag]=eigs(norm_B,maxV,'lm',opts);
end

d=max(max(D));
V2=I1'*V;

V2t = V2(giant_mask(:),2);
[~,idx] = sort(V2t);
comp_n = length(V2t);
C = ones(comp_n,1);
C(idx(1:floor(comp_n/2))) = 2;
class = zeros(n,1);
class(giant_mask) = C;
end
