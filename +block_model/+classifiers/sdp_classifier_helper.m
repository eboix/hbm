function [X,vout] = sdp_classifier_helper(giant_A)
    giant_n = size(giant_A,1);
  %  disp('Starting sdp');
    cvx_begin sdp quiet
        variable X(giant_n,giant_n) semidefinite
        maximize(trace(giant_A*X))
        X*ones(giant_n,1) == 0
        diag(X) == 1
    cvx_end
    vout = cell(0);
end