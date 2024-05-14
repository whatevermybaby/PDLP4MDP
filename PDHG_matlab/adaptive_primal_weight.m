function [w] = adaptive_primal_weight(w, theta, x, y, x0, y0)

nrm_delta_x = norm(x - x0);
nrm_delta_y = norm(y - y0);

if nrm_delta_x > 0 && nrm_delta_y > 0
    w = max(min(exp(theta * log(nrm_delta_y / nrm_delta_x) + (1-theta) * log(w)), 1e2), 1e-2);
%     w = exp(theta * log(nrm_delta_y / nrm_delta_x) + (1-theta) * log(w));
end

end