probs = sym(zeros(2,2,2,2)); % u, a, b, F(u)
syms a0 a1 b0 b1 Fu0 Fu1;
av = [a0 a1];
bv = [b0 b1];
Fuv = [Fu0 Fu1];
for u = 0:1
    for a = 0:1
           tav = av(u+1);
           if a == 1
               tav = 1 - tav;
           end
           for b = 0:1
               tbv = bv(u+1);
               if b == 1
                   tbv = 1 - tbv;
               end
               for Fu = 0:1
                   tFuv = Fuv(u+1);
                   if Fu == 1
                       tFuv = 1 - tFuv;
                   end
                   [u a b Fu];
                   pv = tav * tbv * tFuv * sym(1/2);
                   probs(u+1,a+1,b+1,Fu+1) = pv;
               end
           end
    end
end

pa = sym(zeros(1,2));
for a = 1:2
    csum = 0;
    for u = 1:2
        for b = 1:2
            for Fu = 1:2
                csum = csum + probs(u,a,b,Fu);
            end
        end
    end
    pa(a) = csum;
end

pb = sym(zeros(1,2));
for b = 1:2
    csum = 0;
    for u = 1:2
        for a = 1:2
            for Fu = 1:2
                csum = csum + probs(u,a,b,Fu);
            end
        end
    end
    pb(b) = csum;
end


pab = sym(zeros(2,2));
for a = 1:2
    for b = 1:2
        csum = 0;
        for u = 1:2
            for Fu = 1:2
                csum = csum + probs(u,a,b,Fu);
            end
        end
        pab(a,b) = csum;
    end
end

pabFu = sym(zeros(2,2,2));
for a = 1:2
    for Fu = 1:2
        for b = 1:2
            csum = 0;
            for u = 1:2
                csum = csum + probs(u,a,b,Fu);
            end
            pabFu(a,b,Fu) = csum;
        end
    end
end

paFu = sym(zeros(2,2));
for a = 1:2
    for Fu = 1:2
        csum = 0;
        for b = 1:2
            csum = csum + pabFu(a,b,Fu);
        end
        paFu(a,Fu) = csum;
    end
end

pbFu = sym(zeros(2,2));
for b = 1:2
    for Fu = 1:2
        csum = 0;
        for a = 1:2
            csum = csum + pabFu(a,b,Fu);
        end
        pbFu(b,Fu) = csum;
    end
end

pFu = sym(zeros(1,2));
for Fu = 1:2
    csum = 0;
    for b = 1:2
        csum = csum + pbFu(b,Fu);
    end
    pFu(Fu) = csum;
end

pa(:) = simplify(pa(:));
pb(:) = simplify(pb(:));
pab = simplify(pab(:));
paFu = simplify(paFu(:));
pbFu = simplify(pbFu(:));
pabFu = simplify(pabFu(:));

Ha = calc_entropy(pa(:));
Hb = calc_entropy(pb(:));
Hab = calc_entropy(pab(:));
HaFu = calc_entropy(paFu(:));
HbFu = calc_entropy(pbFu(:));
HabFu = calc_entropy(pabFu(:));
HFu = calc_entropy(pFu(:));
HacondFu = HaFu - HFu;
HbcondFu = HbFu - HFu;
HabcondFu = HabFu - HFu;

IabFu = Hab - HabcondFu;
IaFu = Ha - HacondFu;
IbFu = Hb - HbcondFu;

inf_theory_bound = simplify((Ha - HacondFu + Hb - HbcondFu) - Hab + HabcondFu);
fun = @(x) eval_a_b_Fu(inf_theory_bound,x);

% eval_a_b_Fu(Ha,[0.1 0.1 0.1 0.1 0.1 0.1])

% fun = @(x) vpa(subs(subs(expr,'err1',sym(x(1))),'err2',sym(x(2))),100);
 %   a = fminsearch(fun, [0.5 0.5]);
 %   val = fun(a);

% function res = test_binary_conditioning()
% 
% 
%     function p = get_config_prob(a_val,b_val,c_val)
%         
%     end
% 
% end