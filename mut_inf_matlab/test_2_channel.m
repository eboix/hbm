syms alpha beta gamma delta;
delta = 1 - alpha - beta - gamma;

Hab = 1 + calc_entropy([alpha + delta; beta + gamma]);
HabMidx = calc_entropy([alpha; delta; beta; gamma]);
Ha = 1;
Hb = 1;
HaMidx = calc_entropy([alpha + beta; delta + gamma]);
HbMidx = calc_entropy([alpha + gamma; beta + delta]);

fun = @(x) vpa(subs(subs(subs(simplify((HabMidx - HaMidx - HbMidx) - (Hab - Ha - Hb)),'alpha',x(1)),'beta',x(2)),'gamma',x(3)),100);
FUN = matlabFunction(simplify((HabMidx - HaMidx - HbMidx) - (Hab - Ha - Hb)));

num_trials = 1000000;
vals = zeros(1,num_trials);
V = zeros(num_trials,4);
for i = 1:num_trials
   abvals = rand(1,4);
   a00 = abvals(1);
   
   a10 = 1 - a00;
 %   a10 = abvals(2);
   b00 = abvals(3);
   
   b10 = 1 - b00;
%    b10 = abvals(4);
   
   a01 = 1 - a00;
   a11 = 1 - a10;
   b01 = 1 - b00;
   b11 = 1 - b10;
   
   kern = [[a00*b00 a01*b00 a00*b01 a01*b01]; [a10*b00 a11*b00 a10*b01 a11*b01]; [a00*b10 a01*b10 a00*b11 a01*b11]; [a10*b10 a11*b10 a10*b11 a11*b11]];
   vs = rand(1,6);
   wts = zeros(1,4);
   wts(1) = vs(1)*vs(3)*vs(5);
   wts(2) = vs(1)*vs(4)*vs(6);
   wts(3) = vs(2)*vs(3)*vs(6);
   wts(4) = vs(2)*vs(4)*vs(5);
   
   x = zeros(1,4);
   for j = 1:4
    x = x + wts(j)*kern(j,:);
   end
   x = x / norm(x,1);
   V(i,:) = x(:);
   vals(i) = FUN(x(1),x(2),x(3));
   if vals(i) < 0
       if(fun(x(1:3)) >= 0), continue; end
       wts
       abvals
       kern
       x
       vals(i)
       break
   end
end
min(vals)