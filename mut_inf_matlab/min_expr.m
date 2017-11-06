function [val, a] = min_expr(expr)
    fun = @(x) vpa(subs(subs(expr,'err1',sym(x(1))),'err2',sym(x(2))),100);
    a = fminsearch(fun, [0.5 0.5]);
    val = fun(a);
end