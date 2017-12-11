function s = calc_entropy(vect)
    s = 0;
    for i = 1:length(vect)
        temp = vect(i);
        if temp == 0
            continue;
        end
        s = s - temp * log(temp)/log(sym(2));
    end
end