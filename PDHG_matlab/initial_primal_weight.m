function [w] = initial_primal_weight(data)
    nrm_c = norm(data.c);
    nrm_q = sqrt(norm(data.h)^2 + norm(data.b)^2);
    
    if nrm_c > 0 && nrm_q > 0
        w = nrm_c / nrm_q;
    else
        w = 1;
    end
end