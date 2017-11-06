function [val, a] = max_expr(expr)
    [val, a] = min_expr(-expr);
    val = -val;
end