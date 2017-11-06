function pow_A = pow_graph(A,c)

    G = graph(A,'upper');
    diam_approx = max(distances(G,1)); % 2-approximation of the diameter.
    r_pow = max(floor(c * (log(diam_approx))^3),1)
    
    % Add an edge between every pair of vertices that had a path of length
    % r or less between them.
    pow_A = A^r_pow;
    pow_A(pow_A > 0) = 1;

end