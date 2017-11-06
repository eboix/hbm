function mut_inf = get_symbolic_mut_inf(n, m, edge_list)
% n = # of vertices.
% m = # of edges.
% vertex 1 will be vertex whose label is unknown. 
% vertex n will be vertex whose label is known to be 0.
% edge_list is m x 2 array of rows [u v].
% Don't throw things bigger than n + m = 20 at this.
% Returns mut_inf, function of err1 and err2. Don't plug in 0 or 1 as
% errors, since you will divide by zero :(. Instead plug in small values to
% simulate the same result.

N = n + m;

syms err1 err2;
prob = cell(1,2^(N-1));
for vv=0:2^(n-1)-1,
    vstat = sprintf('%0*s', n-1, dec2bin(vv));
    
    for ee=0:2^m-1
        estat = sprintf('%0*s', m, dec2bin(ee));
        currstat = [vstat '0' estat];
        cp = sym(1/2^(n-1));
        
        for j = 1:size(edge_list,1)
            u = edge_list(j,1);
            v = edge_list(j,2);
            e = j + n;
            if currstat(u) == currstat(v)
                if(currstat(e) == '1'), cp = cp * (1-err2); 
                else cp = cp * err2; end
            else
                if(currstat(e) == '1'), cp = cp * err1;
                else cp = cp * (1-err1); end
            end
        end
        prob{bin2dec([vstat estat])+1} = cp;
    end
end

H = sym(0);
for abc = 0:2^m-1
    abcsum = cell(1,2);
    abcsum{1} = 0;
    abcsum{2} = 0;
    abcstat = sprintf('%0*s', m, dec2bin(abc));
    for rho=0:1
        rhostat = sprintf('%0*s', 1, dec2bin(rho));
        for x = 0:2^(n-2)-1
            if n > 2
                xstat = sprintf('%0*s', n-2, dec2bin(x));
            else
                xstat = '';
            end
            abcsum{rho+1} = abcsum{rho+1} + prob{bin2dec([rhostat xstat abcstat])+1};
        end
    end
    abcnorm = abcsum{1} + abcsum{2};
    p = abcsum{1} / abcnorm;
    q = 1 - p;
    if q == 0
        Hcontrib = -abcnorm * (p*log2(p));
    elseif p == 0
        Hcontrib = -abcnorm * (q*log2(q));
    else
        Hcontrib = -abcnorm * (p*log2(p) + q*log2(q));
    end
    H = H + Hcontrib;
end

mut_inf = 1 - H;
disp('Calculated everything symbolically');

% errvals = 0.01:0.01:0.9;
% Hvals = [];
% for i = errvals
%     Hvals = [Hvals; subs(subs(H, err1, i), err2, 0.00001)];
% end
% mutinfvals = 1 - Hvals;
% plot(errvals, 1-Hvals);


end