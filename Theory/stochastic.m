function M = stochastic(n)
% Generates a nxn stochastic matrix

    M = zeros(n);
    for k = 1:n
        c = rand(n,1); 
        c = c./sum(c);
        M(k,:) = c';
    end
end