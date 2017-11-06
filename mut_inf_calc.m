% p = 0:0.01:4;
% T = 20;
% mc = zeros(1,length(p));
% ms = zeros(1,length(p));
% mc1 = zeros(1,length(p));
% for i = 1:length(p)
%     cp = p(i);
%     [mc(i), exp_state] = mut_inf_corr(cp,T);
%     [mc1(i),~] = mut_inf_corr(cp,1);
%     ms(i) = mut_inf_stringy(exp_state,T);
% end
% 
% close all
% plot(p,ms,'r');
% hold on
% plot(p,mc,'b');
% hold off
% 
% % AWESOME!
% 

syms a b c
eqn1 = a*0.36 + b*0.48 + c*0.08 == 0.4;
eqn2 = (1-a-c)*0.36 + (1-2*b)*0.48 + (1-a-c)*0.08 == 0.4;
eqn3 = c*0.36 + b*0.48 + a*0.08 == 0.2;
[A,B] = equationsToMatrix([eqn1, eqn2, eqn3], [a, b, c]);
X = linsolve(A,B)