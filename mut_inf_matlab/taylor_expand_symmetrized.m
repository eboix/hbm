function [res,tayexp] = taylor_expand_symmetrized(expr,order)
    syms x;
    symmetricexpr = subs(subs(expr,'err1',x+0.5),'err2',x+0.5);
    symmetricexpr = simplify(symmetricexpr);
    tayexp = simplify(taylor(symmetricexpr,x,0,'Order',order));
    [c,t] = coeffs(tayexp);
    res = fliplr([t; c]);
    % ezplot(symmetricexpr, [0 1]);
end