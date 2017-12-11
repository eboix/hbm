function [val, a] = min_t_expr(expr)
    fun = @(x) vpa(subs(subs(expr,'t',sym(x(1))),'err',sym(x(2))),100);
    a = fminsearch(fun, [0.9 0.6]);
    val = fun(a);
end