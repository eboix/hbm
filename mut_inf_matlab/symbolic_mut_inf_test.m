% 2-vertex path.
n = 2;
m = 1;
edge_list = [[1 2]];
p2inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% 3-vertex path.
n = 3;
m = 2;
edge_list = [[1 2]; [2 3]];
p3inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% 4-vertex path.
n = 4;
m = 3;
edge_list = [[1 2]; [2 3]; [3 4]];
p4inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 5-vertex path.
% n = 5;
% m = 4;
% edge_list = [[1 2]; [2 3]; [3 4]; [4 5]];
% p5inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 6-vertex path.
% n = 6;
% m = 5;
% edge_list = [[1 2]; [2 3]; [3 4]; [4 5]; [5 6]];
% p6inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 7-vertex path.
% n = 7;
% m = 6;
% edge_list = [[1 2]; [2 3]; [3 4]; [4 5]; [5 6]; [6 7]];
% p7inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 4-clique.
% n = 4;
% m = 6;
% edge_list = [[1 2]; [1 3]; [1 4]; [2 3]; [2 4]; [3 4]];
% k4inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 2-cycle (2 parallel edges).
% n = 2;
% m = 2;
% edge_list = [[1 2]; [1 2]];
% c2inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 3 parallel edges.
% n = 2;
% m = 3;
% edge_list = [[1 2]; [1 2]; [1 2]];
% par3inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 4 parallel edges.
% n = 2;
% m = 4;
% edge_list = [[1 2]; [1 2]; [1 2]; [1 2]];
% par4inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 5 parallel edges.
% n = 2;
% m = 5;
% edge_list = [[1 2]; [1 2]; [1 2]; [1 2]; [1 2]];
% par5inf = get_symbolic_mut_inf(n,m,edge_list);

% Lasso
n = 3;
m = 3;
edge_list = [[1 2]; [2 3]; [2 3]];
lassoinf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % C3
% n = 3;
% m = 3;
% edge_list = [[1 2]; [2 3]; [1 3]];
% c3inf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % 4-clique with some extra edges designed to test the limits of the bound.
% n = 4;
% m = 8;
% edge_list = [[1 2]; [1 3]; [1 4]; [2 3]; [2 4]; [3 4]; [2 3]; [2 3]];
% k4extrainf = get_symbolic_mut_inf(n,m,edge_list);

% % Bad general when fixed.
% n = 4;
% m = 5;
% edge_list = [[1 2]; [1 3]; [2 3]; [2 4]; [3 4]];
% badgeninf = get_symbolic_mut_inf(n,m,edge_list);

% Series of 2 parallel edges. (Figure Eight).
% n = 3;
% m = 4;
% edge_list = [[1 2]; [1 2]; [2 3]; [2 3]];
% fig8inf = get_symbolic_mut_inf(n,m,edge_list);

% Figure 8 with shortcut.
% n = 3;
% m = 5;
% edge_list = [[1 2]; [1 2]; [2 3]; [2 3]; [1 3]];
% fig8modinf = get_symbolic_mut_inf(n,m,edge_list);

% 
% [~,p2tay] = taylor_expand_symmetrized(p2inf,40);
% [~,p3tay] = taylor_expand_symmetrized(p3inf,40);
% [~,p4tay] = taylor_expand_symmetrized(p4inf,40);
% [~,p5tay] = taylor_expand_symmetrized(p5inf,40);
% [~,p6tay] = taylor_expand_symmetrized(p6inf,40);
% [~,p7tay] = taylor_expand_symmetrized(p7inf,40);
% [~,c2tay] = taylor_expand_symmetrized(c2inf,40);
% [~,c3tay] = taylor_expand_symmetrized(c3inf,40);
% [~,par3tay] = taylor_expand_symmetrized(par3inf,40);
% [~,par4tay] = taylor_expand_symmetrized(par4inf,40);
% [~,par5tay] = taylor_expand_symmetrized(par5inf,40);
% [~,lassotay] = taylor_expand_symmetrized(lassoinf,40);
% [~,k4extratay] = taylor_expand_symmetrized(k4extrainf,40);
% [~,fig8tay] = taylor_expand_symmetrized(fig8inf,40);
% [~,fig8modtay] = taylor_expand_symmetrized(fig8modinf,40);

% [c,t] = coeffs(p2tay + 4*p3tay - fig8modtay);
% res = fliplr([t; c*log(sym(2))])

% approx = p2inf + 2*p3inf + 2*p4inf; % Good up to O(x^6). Even orders.
% approx = p2inf + 2*p3inf; % Good up to O(x^8). Even orders.
% expr = approx - k4inf;

% ezsurfc(approx,[0 1])
% hold on
% ezsurfc(expr,[0 1])

% 
% % Example graph from today.
% n = 3;
% m = 3;
% edge_list = [[1 2]; [2 3]; [2 3]];
% sampleinf = get_symbolic_mut_inf(n,m,edge_list);
% 
% % Try to minimize this expression, to see if 2*p2inf >= sampleinf always!
% expr = 2*p2inf - sampleinf;
% ezsurfc(expr,[0 1])
% hold on
% ezsurfc(sampleinf,[0 1])
% view(127,38)