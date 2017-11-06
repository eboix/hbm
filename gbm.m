classdef gbm
    % Subsampled geometric block model on cube, torus, or sphere.
    properties
        n; % Number of vertices.
        k; % Number of communities.
        prob_dist; % Community --> Relative share of community.
        
        % GBM params.
        thresh; % Threshold distance.
        d; % Dimension. 
        Q; % Connectivity matrix.
        pos; % List of the positions of the points.
        type; % Either 'sphere' or 'torus'.
        
        % True guesses.
        community; % Vector. Vertex --> Community.
        n_community; % Vector. Community --> Number of vertices.
        
        % Graph
        adj_list; % Calculated adjacency list.
    end
    
    methods
        
        function obj=gbm(n,prob_dist,thresh,Q,d,type)
            % n is number of vertices.
            % prob_dist is relative share.
            % Parameters:
            %   thresh is threshold distance.
            %   d is the dimension.
            %   Q is connectivity matrix.
            %   type could be 'sphere' or 'torus' or 'cube'. Default is 'cube'.
            
            
            if nargin <= 5
                type = 'cube';
            end
            
            obj.n = n;
            obj.prob_dist = prob_dist;
            obj.k = length(prob_dist);
            obj.thresh = thresh;
            assert(issymmetric(Q));
            obj.Q = Q;
            obj.d = d;
            obj.type = type;

            % Code can be optimized a bit, but not worth it right now.
            obj.community = sort(randp(prob_dist, n, 1));
            obj.n_community = arrayfun(@(i) sum(obj.community==i), 1:obj.k);
            
            if strcmpi(obj.type,'sphere')
                pos = normrnd(0,1,n,obj.d+1);
                pos = normr(pos);
                obj.pos = pos;
            elseif strcmpi(obj.type,'torus')
                assert(0, 'Not yet implemented.');
            elseif strcmpi(obj.type,'cube') % Unit cube centered at (1/2, 1/2).
                pos = rand(n,obj.d);
                obj.pos = pos;
            else
                assert(0, 'Invalid gbm type.');
            end

            % Construct the graph using a KD-Tree for greater efficiency.
            % 3.2 seconds on 200,000 vertices, T = 15/sqrt(n).
            % Versus 76 seconds with exhaustive search.
            % This is the bottleneck of the program.
            GrphKDT = KDTreeSearcher(pos);
            adj_list = rangesearch(GrphKDT,pos,thresh); % Get adj list.
            templ = cellfun(@(x) length(x), adj_list); % THIS LINE IS A(N UNECESSARY?) BOTTLENECK.
            adj_list = [rldecode(templ, 1:n); adj_list{:}]';
          %  disp(adj_list)
            adj_list = adj_list(adj_list(:,1) < adj_list(:,2),:); % List each edge once.
            
            % Sort within each left community --> can then cut up the right
            % communities.
            tmp_adj_list = zeros(0,2);
            beg = 1;
            for i = 1:obj.k
                % Split off the i edges.
                fin = beg + obj.n_community(i) - 1;
                comm_range = beg:fin;
                [idx1,idx2] = find_in_sorted(adj_list(:,1),comm_range);
                curr_view = adj_list(idx1:idx2,:);
                curr_view = sortrows(curr_view,2);
                beg_inner = beg;
                for j = i:obj.k
                    currp = Q(i,j);
                    fin_inner = beg_inner + obj.n_community(j) - 1;
                    [idx1,idx2] = find_in_sorted(curr_view(:,2),beg_inner:fin_inner);
                    curr_edges = curr_view(idx1:idx2,:);
                    curr_edges = curr_edges(rand(1,length(curr_edges)) < Q(i,j),:);
                    tmp_adj_list = [tmp_adj_list; curr_edges];
                    beg_inner = fin_inner + 1;
                end
                beg = fin + 1;
            end
            clear('adj_list');
            obj.adj_list = tmp_adj_list;
            
        end
        
        function plot_classifications(obj, class)
            if obj.d ~= 2 || ~strcmpi(obj.type,'cube')
                error('Geo block model should be cube in 2 dimensions.')
            end
            subplot(2,2,1)
            wh = ceil([50 50]);
            
            limits = [0 1 0 1];
            [~, ~, minmaxscaling] = cropped_density([obj.pos(:,1), obj.pos(:,2)], wh, limits);
            title('All points');
            for c = 0:2
                subplot(2,2,c+2);
                cropped_density([obj.pos(class==c,1), obj.pos(class==c,2)], wh, limits, minmaxscaling);
                title(sprintf('Class %d',c));
            end
        end
        
        function [agreement, perm] = classification_agreement(obj, class)
            magg = 0;
            mperm = 1:obj.k;
            for perm = perms(1:obj.k)
                agg = 0;
                for i = 1:obj.k
                    fk = (obj.community == i);
                    ck = (class==perm(i));
                    agg = agg + sum(fk & ck);
                end
                if agg > magg
                    magg = agg;
                    mperm = perm;
                end
            end
            agreement = magg/obj.n;
            perm = mperm;
        end
    
        function [sparseg,A] = get_graph(obj,A)
            % Adjacency matrix A is an optional parameter.
            if nargin == 1
                A = obj.get_adj_matrix();
            end
            sparseg = graph(A,'upper');
        end
        
        function A = get_adj_matrix(obj)
            num_edges = length(obj.adj_list(:,1));
            A = sparse(obj.adj_list(:,1), obj.adj_list(:,2),1,obj.n,obj.n,num_edges);
            A = A + A';
        end
        
        function [giant_A,giant_mask,giant_rev,A,sparseg] = get_giant_adj_matrix(obj,A,sparseg)
            % Returns adj matrix, giant_A, for largest component.
            % Calculates A and sparseg if not yet calculated.
            % giant_A = A(giant_mask, giant_mask).
            % giant_rev maps from giant_A indices to A indices.
            if nargin == 1
                [sparseg,A] = get_graph(obj);
            elseif nargin == 2
                [sparseg,~] = get_graph(obj,A);
            elseif nragin ~= 3
                error('Invalid number of arguments.');
            end
            
            [~,comp] = obj.get_comp_sizes(sparseg);
            giant_mask = (comp == 1);
            giant_rev = find(giant_mask);
            giant_A = A(giant_mask, giant_mask); 
        end
        
        function [sbincount, comp] = get_comp_sizes(obj,sparseg)
            % Returns component sizes in descending order, and index array of
            % vertex to component. 1 is largest comp, length(sbincount) is
            % smallest component.
            if nargin == 1
                sparseg = get_graph(obj);
            end
            comp = conncomp(sparseg);
            binrange = 1:max(comp);
            bincount = histc(comp, binrange);
            [sbincount, idx] = sort(bincount, 'descend');
            inv_idx(idx) = 1:length(idx); % Invert permutation.
            comp = inv_idx(comp);
        end
        
    end
end
