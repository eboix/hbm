function class=nb_classifier(obj,giant_mask)
    % CODE FROM COLIN SANDON'S THESIS. NBTRACKING WALK CLASSIFIER.
    % MODIFIED BY ENRIC FOR EFFICIENCY.
    % obj is a hybrid_block_model object.
    %Attempts to divide a graph’s vertices into clusters by using the dominant
    %eigenvectors of the graph’s nonbacktracking walk matrix.
    %This function outputs a list of length n that lists a number from 0 to k
    %for each vertex. 1 to k are the communities, while vertices that are
    %outside the main component get an entry of 0 in the output.
    %Computes the graph’s nonbacktracking walk matrix.

%  disp('Running nb_classifier');
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
    % About 100s of times faster on 550,000 edges, n = 20,000!
    Gt = G'; % transpose
    I1vec = [1:2*e; Gt(1:end)]; % read in column major order
    I1 = sparse(I1vec(1,:),I1vec(2,:),1,2*e,n);
    
    Gt = [G(:,2) G(:,1)]; % swap columns
    Gt = Gt'; % transpose
    I2vec = [1:2*e; Gt(1:end)]; % read in column major order
    I2 = sparse(I2vec(1,:),I2vec(2,:),1,2*e,n);

% OLD CODE:
%     I1 = spalloc(2*e,n,2*e);
%     I2 =spalloc(2*e,n,2*e);
%     for i=1:e
%         I1(2*i-1,G(i,1))=1;
%         I1(2*i,G(i,2))=1;
%         I2(2*i-1,G(i,2))=1;
%         I2(2*i,G(i,1))=1;
%     end

    tic
    B=I2*I1';
    
    matrix_side = 2*e;
    B(2:(2*matrix_side+2):end) = 0;
    B((1+matrix_side):(2*matrix_side+2):end) = 0;
% OLD CODE:
%     for i=1:e
%         B(2*i-1,2*i)=0;
%         B(2*i,2*i-1)=0;
%     end

    %Finds the top k eigenvectors of the graph, or as many as it can if that is
    %less than k.
    flag=1;
    maxV=k+1;
    opts.isreal = 1;
    opts.issym = 1;
    opts.tol = 1e-10;
    while flag>0
        maxV=maxV-1;
        [V,D,flag]=eigs(B,maxV,'lm',opts);
    end

%     opts.isreal = 1;
%     opts.issym = 1;
%     opts.v0 = ones(matrix_side,1);
%     tic;
%     [V,D,~]=eigs(B,1,'lm',opts);
%     toc;
    
    
    %Convert the eigenvectors from vectors over the edges to vectors over the
    %vertices, and deletes the entries corresponding to vertices outside the
    %main community.
    d=max(max(D));
    V2=I1'*V;
    
%     indices=zeros(n,1);
%     count=n;
%     V2copy=V2;
%     for i=0:(n-1)
%         if V2(n-i,1)==0
%             V2=[V2(1:n-i-1,:);V2(n-i+1:count,:)];
%             indices=[indices(1:n-i-1,1);indices(n-i+1:count,1)];
%             count=count-1;
%         end
%     end

    % ABBE-SANDON CODE:
%     %Recalibrates the magnitudes of the vectors in an effort to make their
%     %magnitudes correspond to the usefulness of the information they provide.
%     %Also nullifies the first eigenvector (which is irrelevant under standard
%     %assumptions) and any eigenvector with a significantly complex eigenvalue
%     %(the useful eigenvectors should have real eigenvalues).
%     s0=V2'*V2;
%     s=zeros(maxV,maxV);
%     for i=1:maxV
%         l=D(i,i);
%         x=((d-l)^2+l*l)/(d*(l*l-d));
%         s(i,i)=sqrt((1+(1/x))/s0(i,i));
%         if D(i,i)==d
%             s(i,i)=0;
%         end
%         if abs(imag(D(i,i)))>.01
%             s(i,i)=0;
%         end
%     end
%     V2=V2*s;
%     
%     %Runs kmeans to assign the vertices in the main component to communities.
%     [C,C2,dis]=kmeans([real(V2),imag(V2)],k,'replicates',10);
%     %Adds the vertices outside the main component back into the output as being
%     %in an unknown community.

% DIVIDING BY TWO SEEMS MORE EFFECTIVE IN THE SYMMETRIC THRESHOLD GRAPH
% WE'RE CONSIDERING.

V2t = V2(giant_mask(:),2);
[~,idx] = sort(V2t);
comp_n = length(V2t);
C = ones(comp_n,1);
C(idx(1:floor(comp_n/2))) = 2;
class = zeros(n,1);
class(giant_mask) = C;
end
