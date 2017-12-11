syms alpha beta gamma delta;

n = 4;
m = 4;
aux = 2;
N = n+m+aux;

% x y1 y2 z A1 A2 B1 B2 w1 w2
p = cell(1,2^N);

% Variable indices.
x = 1;
y1 = 2;
y2 = 3;
z = 4;
A1 = 5;
A2 = 6;
B1 = 7;
B2 = 8;
w1 = 9;
w2 = 10;

syms t err;
syms W;
% Ft = 2 - 2^(-t+1);
Ft = W;

for ii=0:2^N-1
    stat = sprintf('%0*s', N, dec2bin(ii));
    cp = 1;

    % x
    cp = cp * sym(1/2);
    
    % z
    cp = cp * sym(1/2);
    
    % y1, y2
    if stat(y1) == stat(y2)
        cp = cp * ((1-Ft)/sym(2) + Ft/sym(4));
    else
        cp = cp * (Ft/sym(4));
    end
    
    % w1, w2
    if stat(w1) == stat(w2)
        if stat(w1) == '0'
            cp = cp * ((1-t)*(1-err) + t*(1-err)^2);
        else
            cp = cp * ((1-t)*err + t*err^2);
        end
    else
        cp = cp * (t*err*(1-err));
    end
    
    % A1
    if stat(x) == stat(y1)
        xy1 = '0';
    else
        xy1 = '1';
    end
    if stat(w1) == xy1
        a1 = '0';
    else
        a1 = '1';
    end
    if stat(A1) ~= a1
        cp = 0;
    end
    
    % A2
    if stat(x) == stat(y2)
        xy2 = '0';
    else
        xy2 = '1';
    end
    if stat(w2) == xy2
        a2 = '0';
    else
        a2 = '1';
    end
    if stat(A2) ~= a2
        cp = 0;
    end
        
    % B1
    if stat(y1) == stat(z)
        y1z = '0';
    else
        y1z = '1';
    end
    if stat(B1) == y1z
        cp = cp * (1-err);
    else
        cp = cp * err;
    end
    
    % B2
    if stat(y2) == stat(z)
        y2z = '0';
    else
        y2z = '1';
    end
    if stat(B2) == y2z
        cp = cp * (1-err);
    else
        cp = cp * err;
    end
    
    p{bin2dec(stat)+1} = cp;
end

% x z A1 A2 B1 B2
pABxz = cell(1,2^6);
for ii=1:2^6
    pABxz{ii} = 0;
end
for ii=0:2^N-1
    stat = sprintf('%0*s', N, dec2bin(ii));
    cp = p{ii+1};
    rstat = [stat(1) stat(4) stat(5) stat(6) stat(7) stat(8)];
    jj = bin2dec(rstat)+1;
    pABxz{jj} = pABxz{jj} + cp;
end
for ii=1:2^6
    pABxz{ii} = simplify(pABxz{ii});
end

pAB = cell(4,1);
for x = 0:1
    for z = 0:1
        pAB{x*2+z+1} = [pABxz{2^4*(x*2+z)+1:2^4*(x*2+z+1)}];
    end
end

% FOR THE SYMMETRIC CASE ONLY:

HABCx = calc_entropy((pAB{1} + pAB{2})*2)/2 + calc_entropy((pAB{3} + pAB{4})*2)/2; % Hab given x. % We can assume that x = 0 and take first term, since both will be equal.
HABCxz = calc_entropy(pAB{1}*4)/4 + calc_entropy(pAB{2}*4)/4 + calc_entropy(pAB{3}*4)/4 + calc_entropy(pAB{4}*4)/4; % Hab given x,z. % Amazingly, at least for symmetric channels, we can assume x = z = 0? Haven't checked asymmetric channels yet
IABwzCx = HABCx - HABCxz; % I((A,B); z | x).
FUN = matlabFunction(IABwzCx);

err_val = 0.1;
[x_vals, y_vals] = meshgrid(0:0.001:0.5,0:0.001:1);
Ixy = FUN(x_vals, err_val, y_vals);
pcolor(Ixy);
shading interp;
colormap(jet(65536));
ylabel('t (edge independence). Information should increase -->');
xlabel('W (vertex independence). Information should decrease -->');
% 
% % Lasso
% n = 3;
% m = 3;
% edge_list = [[1 2]; [2 3]; [2 3]];
% lassoinf = get_symbolic_mut_inf(n,m,edge_list);
% lassoinf_sym = subs(subs(lassoinf,'err2',err),'err1',err);
% 
% % 3-vertex path.
% n = 3;
% m = 2;
% edge_list = [[1 2]; [2 3]];
% p3inf = get_symbolic_mut_inf(n,m,edge_list);
% p3inf_sym = subs(subs(p3inf,'err2',err),'err1',err);
% 
% dIdt = diff(IABwzCx,t);
% fun = @(x) vpa(subs(subs(dIdt,'t',sym(x(1))),'err',sym(x(2))),100);
% 
% [val, a] = min_t_expr(dIdt)
