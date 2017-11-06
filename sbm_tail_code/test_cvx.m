echo on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECTION 2.1: LEAST SQUARES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input data
m = 16; n = 8;
A = randn(m,n);
b = randn(m,1);

% Matlab version
x_ls = A \ b;

% cvx version
cvx_begin
    variable x(n)
    minimize( norm(A*x-b) )
cvx_end

echo off