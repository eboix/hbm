classdef hybrid_block_model < handle
    % Hybrid block model with Gaussians of variance 1
    properties
        n; % Number of vertices.
        k; % Number of communities.
        prob_dist; % Community --> Relative share of community.
        t; % 0 means purely SBM. 1 means purely GBM.
        
        % GBM params.
        d; % Dimensions.
        center; % Vector. Community --> Center of community.
        thresh; % Threshold distance.
        pos; % Vector. Vertex --> Position tuple.
        
        % SBM params.
        Q; % Connectivity matrix.
        
        % True guesses.
        community; % Vector. Vertex --> Community.
        n_community; % Vector. Community --> Number of vertices.
        
        % Graph
        adj_list; % Calculated adjacency list.
        
    end
    
    properties (Access = protected)
        % Memoized properties. This is a bit more inefficient than what I
        % was doing before, but much cleaner, and hence probably better!
        
        A; % Sparse adjacency matrix.
        sparseg; % Sparse graph
        giant_A; % Giant adjacency matrix.
        giant_rev; % list of indices in giant.
        giant_mask; % i -> is i in giant?
        
        % Bools for memoization purposes.
        A_memoized = 0;
        sparseg_memoized = 0;
        giant_memoized = 0;
    end
    
    methods
        
        function obj=hybrid_block_model(n,prob_dist,t,center,thresh,Q)
            % n is number of vertices.
            % prob_dist is relative share.
            % t is HBM parameter: 0 for SBM. 1 for GBM. 0 <= t <= 1.
            % Named GBM parameters (if t > 0):
            %   center is k x d matrix.
            %   thresh is threshold distance.
            % Named SBM parameters (if t < 1):
            %   Q is connectivity matrix.
            
            obj.n = n;
            obj.prob_dist = prob_dist;
            obj.k = length(prob_dist);
            obj.t = t;
            assert(0 <= t);
            assert(t <= 1);
            
            k = obj.k;
            % Code can be optimized a bit, but not worth it right now.
            community = block_model.utility.randp(prob_dist, n, 1);
            obj.community = sort(community);
            obj.n_community = arrayfun(@(i) sum(community==i), 1:k);
            
            
            temp_gbm_adj_list = zeros(0,2);
            temp_sbm_adj_list = zeros(0,2); % PREALLOCATE?
            if t ~= 0
                % NEED TO INITIALIZE GBM STUFF.
                obj.center = center;
                center_dim = size(center);
                assert(center_dim(1) == k);
                obj.d = center_dim(2);
                obj.thresh = thresh;
                
                d = obj.d;
                % A bit more than 800 times faster than arrayfun with mvrnd
                pos = normrnd(0,1,n,d);
                beg = 1;
                for i = 1:k
                    fin = beg + obj.n_community(i) - 1;
                    for j = 1:d
                        pos(beg:fin,j) = pos(beg:fin,j) + center(i,j);
                    end
                    beg = fin + 1;
                end
                obj.pos = pos;

                % Construct the graph using a KD-Tree for greater efficiency.
                % 3.2 seconds on 200,000 vertices, T = 15/sqrt(n).
                % Versus 76 seconds with exhaustive search.
                % This is the bottleneck of the program.
                GrphKDT = KDTreeSearcher(pos);
                temp_gbm_adj_list = rangesearch(GrphKDT,pos,thresh); % Get adj list.
                templ = cellfun(@(x) length(x), temp_gbm_adj_list); % THIS LINE IS A BOTTLENECK.
                temp_gbm_adj_list = [rldecode(templ, 1:n); temp_gbm_adj_list{:}]';
                temp_gbm_adj_list = temp_gbm_adj_list(temp_gbm_adj_list(:,1) < temp_gbm_adj_list(:,2),:); % List each edge once.
            end
            
            if t ~= 1
                % NEED TO INITIALIZE SBM STUFF.
                obj.Q = Q;
                assert(all(all(Q == Q'))); % Should be a symmetric matrix.
                assert(length(Q) == k)
                
                % For small probabilities a/n, a log(n) / n, as n gets
                % large, we may estimate the number of edges of each kind
                % with a poisson random variable.
                % Suppose max prob. is a/n. Then
                % All poisson estimates work w.p. \geq 1 - k^2 *(1-t)*a/n.
                begi = 1;
                for i = 1:k
                    ni = obj.n_community(i);
                    fini = begi + ni - 1;
                    begj = begi;
                    for j = i:k
                        nj = obj.n_community(j);
                        finj = begj + nj - 1;
                        exp_edge_num = ni*nj*Q(i,j);
                        rand_num_edges = poissrnd(exp_edge_num);
                          
                        % Remove & replace duplicates:
                        % Expected number of duplicate pairs is about
                        % a^2*ni*nj/n^2, which is constant if a is
                        % constant.
                        % This number roughly doubles if i == j.
                        % This is pretty small, so we can just find the
                        % duplicates and replace them with new random
                        % edges, iteratively.

                        temp_edges = [];
                      %  m = containers.Map('KeyType', 'uint64', 'ValueType', 'logical');

                        while length(temp_edges) < rand_num_edges
                            curr_num_edges = length(temp_edges);
                            num_new_edges = rand_num_edges - curr_num_edges;
                            extra_edges = [randi([begi fini], num_new_edges, 1) randi([begj finj], num_new_edges, 1)];
                            if i == j
                                extra_edges = sort(extra_edges,2);
                            end
                            extra_edges = extra_edges(extra_edges(:,1) ~= extra_edges(:,2),:);
                            temp_edges = [temp_edges; extra_edges];
                            temp_edges = unique(temp_edges,'rows'); % BOTTLENECK.
                        end
                        temp_sbm_adj_list = [temp_sbm_adj_list; temp_edges];
                        begj = finj + 1;
                    end
                    begi = fini + 1;
                end
            end
            
            % obj.adj_list = [temp_gbm_adj_list; temp_sbm_adj_list];
            
            % Combine temp_gbm_adj_list and temp_sbm_adj_list.
            temp_inter = intersect(temp_gbm_adj_list, temp_sbm_adj_list, 'rows');
            curr_num_edges = size(temp_gbm_adj_list, 1);
            temp_gbm_adj_list = temp_gbm_adj_list(rand(1,curr_num_edges) < t,:); % Subsample edges.
            curr_num_edges = size(temp_sbm_adj_list, 1);
            temp_sbm_adj_list = temp_sbm_adj_list(rand(1,curr_num_edges) > t,:);
            obj.adj_list = unique([temp_gbm_adj_list; temp_sbm_adj_list; temp_inter], 'rows');
           
        end
        
        function plot_classifications(obj, class)
            
            import block_model.utility.*;
            if obj.d ~= 2
                error('Geo block model should be in 2 dimensions.')
            end
            subplot(2,2,1)
            wh = ceil([50 50]);
            
            minxcenter = min(obj.center(:,1));
            minycenter = min(obj.center(:,2));
            maxxcenter = max(obj.center(:,1));
            maxycenter = max(obj.center(:,2));
            
            limits = [-3+minxcenter 3+maxxcenter -3+minycenter 3+maxycenter];
            [~, ~, minmaxscaling] = cropped_density([obj.pos(:,1), obj.pos(:,2)], wh, limits);
            title('All vertices','interpreter','latex');
            for c = 0:2
                subplot(2,2,c+2);
                cropped_density([obj.pos(class==c,1), obj.pos(class==c,2)], wh, limits, minmaxscaling);
                
                if c == 0
                    title('Non-giant vertices','interpreter','latex');
                else
                    title(sprintf('Class %d',c),'interpreter','latex','FontName','Times');
                end
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
        
        function [agree, perm] = giant_classification_agreement(obj, class_vec)
            [~,giantmask,~] = obj.get_giant_adj_matrix();
            class_vec(~giantmask) = 0;
            [agree, perm] = obj.classification_agreement(class_vec);
            agree = agree * obj.n / sum(giantmask);
        end
        
        function [agreement, perm] = classification_agreement_geo_predictor(obj, class_vec)
            % Check the classification guess, class, against the MAP guess
            % for when the model is purely a geo_block_model.
            if obj.k ~= 2
                error('There should be exactly two communities for this method to work.')
            end
            if obj.t == 0
                error('There are no calculated positions, as the model is a pure SBM.');
            end
            magg = 0;
            mperm = 1:obj.k;
            for perm = perms(1:obj.k)
                agg = 0;
                for i = 1:obj.k
                    fk = ((-1)^i .* (obj.pos(:,1)-(obj.center(1,1)+obj.center(2,1))/2) > 0);
                    ck = (class_vec==perm(i));
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
    
        function sparseg = get_graph(obj)
            if ~obj.sparseg_memoized
                obj.init_sparseg_memoize()
            end
            sparseg = obj.sparseg;
        end
        
        function A = get_adj_matrix(obj)
            if ~obj.A_memoized
                obj.init_adj_matrix_memoize();
            end
            A = obj.A;
        end
        
        function [giant_A,giant_mask,giant_rev] = get_giant_adj_matrix(obj)
            % Returns adj matrix, giant_A, for largest component.
            % giant_A = A(giant_mask, giant_mask).
            % giant_rev maps from giant_A indices to A indices.
            if ~obj.giant_memoized
                obj.init_giant_memoize()
            end
            giant_A = obj.giant_A;
            giant_mask = obj.giant_mask;
            giant_rev = obj.giant_rev;
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
    
    methods (Access = private)
        
        function init_adj_matrix_memoize(obj)
            num_edges = length(obj.adj_list(:,1));
            obj.A = sparse(obj.adj_list(:,1), obj.adj_list(:,2),1,obj.n,obj.n,num_edges);
            obj.A = obj.A + obj.A';
            obj.A_memoized = 1;
        end
        
        function init_sparseg_memoize(obj)
            if ~obj.A_memoized
                obj.init_adj_matrix_memoize()
            end
            obj.sparseg = graph(obj.A,'upper');
            obj.sparseg_memoized = 1;
        end
        
        function init_giant_memoize(obj)
            if ~obj.A_memoized
                obj.init_adj_matrix_memoize();
            end
            if ~obj.sparseg_memoized
                obj.init_sparseg_memoize();
            end
            [~,comp] = obj.get_comp_sizes(obj.sparseg);
            obj.giant_mask = (comp == 1);
            obj.giant_rev = find(obj.giant_mask);
            obj.giant_A = obj.A(obj.giant_mask, obj.giant_mask); 
            obj.giant_memoized = 1;
        end
    end
end
