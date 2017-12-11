% % % 2-vertex path.
% % n = 2;
% % m = 1;
% % edge_list = [[1 2]];
% % p2inf = get_symbolic_mut_inf_general(n,m,edge_list);
% % 
% % 3-vertex path.
% n = 3;
% m = 2;
% edge_list = [[1 2]; [2 3]];
% p3inf = get_symbolic_mut_inf_general(n,m,edge_list);
% % 4-vertex path.
% n = 4;
% m = 3;
% edge_list = [[1 2]; [2 3]; [3 4]];
% p4inf = get_symbolic_mut_inf_general(n,m,edge_list);
% 
% 
% % Bad general when fixed.
% % n = 4;
% % m = 5;
% % edge_list = [[1 2]; [1 3]; [2 3]; [2 4]; [3 4]];
% % badgeninf = get_symbolic_mut_inf_general(n,m,edge_list);
% % % 5-vertex path.
% n = 5;
% m = 4;
% edge_list = [[1 2]; [2 3]; [3 4]; [4 5]];
% p5inf = get_symbolic_mut_inf_general(n,m,edge_list);
% % K4
% % n = 4;
% % m = 6;
% % edge_list = [[1 2]; [1 3]; [2 3]; [2 4]; [3 4]; [1 4]];
% % k4inf = get_symbolic_mut_inf_general(n,m,edge_list);
% % K4 with tail
% n = 5;
% m = 7;
% edge_list = [[1 2]; [1 3]; [2 3]; [2 4]; [3 4]; [1 4]; [4 5]];
% k4withtailinf = get_symbolic_mut_inf_general(n,m,edge_list);
% 
% % 
%  FUN = matlabFunction(k4withtailinf);
%  clear k4withtailinf;
% % p2FUN = matlabFunction(p2inf);
% p3FUN = matlabFunction(p3inf);
% p4FUN = matlabFunction(p4inf);
% p5FUN = matlabFunction(p5inf);


num_trials = 100000;
vals = zeros(num_trials,1);
for i = 1:num_trials
   errs = rand(1,14);
   pars = num2cell(errs);
   a = FUN(pars{:});
   left_path = p4FUN(errs(1),errs(2),errs(7),errs(8),errs(13),errs(14));
   right_path = p4FUN(errs(3),errs(4),errs(9),errs(10),errs(13),errs(14));
   left_zig = p5FUN(errs(1),errs(2),errs(5),errs(6),errs(9),errs(10),errs(13),errs(14));
   right_zig = p5FUN(errs(3),errs(4),errs(5),errs(6),errs(7),errs(8),errs(13),errs(14));
   short_path = p3FUN(errs(11),errs(12),errs(13),errs(14));
   vals(i) = short_path + left_path + right_path + left_zig + right_zig - a;
end