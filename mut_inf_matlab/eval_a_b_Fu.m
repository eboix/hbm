function v = eval_a_b_Fu(expr,vec_vals)
texpr = subs(expr,'a0',sym(vec_vals(1)));
texpr = subs(texpr,'a1',sym(vec_vals(2)));
texpr = subs(texpr,'b0',sym(vec_vals(3)));
texpr = subs(texpr,'b1',sym(vec_vals(4)));
texpr = subs(texpr,'Fu0',sym(vec_vals(5)));
texpr = subs(texpr,'Fu1',sym(vec_vals(6)));
v = vpa(texpr,1000);
end