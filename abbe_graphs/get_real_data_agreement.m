function [agreement,perm] = get_real_data_agreement(true_class,class_guess,varargin)
% class_guess == 0 iff not in giant, so we ignore those.
    p = inputParser;
    addParameter(p, 'k',-1,@(x) (isnumeric(x) && isscalar(x) && x > 0));
    parse(p,varargin{:});
    k = p.Results.k;
    if(k < 0), error('Specify k!'); end
    magg = 0;
    mperm = 1:k;
    for perm = perms(1:k)
        agg = 0;
        for i = 1:k
            fk = (true_class== i);
            ck = (class_guess==perm(i));
            agg = agg + sum(fk & ck);
        end
        if agg > magg
            magg = agg;
            mperm = perm;
        end
    end
    agreement = magg/sum(class_guess ~= 0);
    perm = mperm;

end