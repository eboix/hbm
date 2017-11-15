function [class,vout]=nb_classifier(obj,varargin)
% CODE FROM COLIN SANDON'S THESIS. NBTRACKING WALK CLASSIFIER. MODIFIED BY
% ENRIC FOR SOME EXTRA EFFICIENCY.
% obj is a hybrid_block_model object.
% Attempts to divide a graph's vertices into clusters by using the dominant
% eigenvectors of the graph's nonbacktracking walk matrix. This function
% outputs a list of length n that lists a number from 0 to k for each
% vertex. 1 to k are the communities, while vertices that are outside the
% main component get an entry of 0 in the output. Computes the graph's
% nonbacktracking walk matrix.

% disp('Running nb_classifier');

    function [class_matrix,vout] = nb_helper(giant_A,k)
        
        n = size(giant_A,1);
        
        % n x 2 list of undirected edges. Each edge appears exactly once.
        [rows,cols] = find(triu(giant_A));
        giant_edge_list = [rows cols];
        e = size(giant_edge_list,1);
        
        % Split undirected edges into two directed edges each (total of 2e
        % directed edges). Then construct I1 and I2.
        
        % I1 is sparse (2e) X n matrix with 1 in (i,j) entry if vertex j is
        % tail of directed edge i.
        Gt = giant_edge_list';
        I1vec = [1:2*e; Gt(1:end)]; % read in column major order
        I1 = sparse(I1vec(1,:),I1vec(2,:),1,2*e,n);
        
        % I2 is sparse (2e) X n matrix with 1 in (i,j) entry if vertex j is
        % head of directed edge i.
        Gt = [giant_edge_list(:,2) giant_edge_list(:,1)]; % swap columns
        Gt = Gt';
        I2vec = [1:2*e; Gt(1:end)]; % read in column major order
        I2 = sparse(I2vec(1,:),I2vec(2,:),1,2*e,n);
        
        % Construct the non-backtracking matrix B, (2e) X (2e). (i,j) is 1
        % iff head of directed edge i is tail of directed edge b, and i is
        % not j in reverse orientation.
        B=I2*I1';
        matrix_side = 2*e;
        B(2:(2*matrix_side+2):end) = 0;
        B((1+matrix_side):(2*matrix_side+2):end) = 0;
        
        % Finds the top k eigenvectors of B, or as many as it can if that
        % is less than k.
        flag=1;
        maxV=k+1;
        opts.isreal = 1;
        opts.issym = 1;
        opts.tol = 1e-14;
        while flag > 0
            maxV=maxV-1;
            [V,Dd,flag]=eigs(B,maxV,'lr',opts);
           % MATLAB DOES NOT AUTOMATICALLY SORT EIGS IN R2017a AND BELOW:
           [Dd,I] = sort(diag(Dd),'descend');
            V2 = V(:,I);
            V2 = V(:,2:end);
        end
    
        % class_matrix is n X 2k. Values of eigenvectors have been
        % consolidated into tails of directed edges.
        if all(imag(V2) == 0)
            V2 = real(V2);
        else
            V2 = [real(V2) imag(V2)];
        end
        class_matrix=I1'*V2;
        vout = cell(0); % No extra outputs.
    end


[class,vout] = base_giant_classifier(@nb_helper, obj, varargin{:});

end

