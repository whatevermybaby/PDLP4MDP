function [err_p, err_d, err_gap, obj_p, obj_d, inf_res, unb_res] = convergence_check(work, data, x, y, ind_nneg)

m1 = length(data.h);
m2 = length(data.b);
% m = m1 + m2;
% n = length(data.c);

norm_type = 'inf';

err_p = norm(work.D .* [min(data.G*x-data.h, 0); data.A*x-data.b], norm_type) / (1 + max([work.nm_h; work.nm_b])) / (work.sc_b);

res_d = data.c-data.G'*y(1:m1)-data.A'*y(m1+1:m1+m2);
res_d(ind_nneg) = min(res_d(ind_nneg), 0);
err_d = norm(work.E .* res_d, norm_type) / (1 + max(work.nm_c)) / (work.sc_c);

obj_p = full(data.c' * x / (work.sc_c * work.sc_b)) + data.Const;
obj_d = full((data.h' * y(1:m1) + data.b' * y(m1+1:m1+m2)) / (work.sc_c * work.sc_b)) + data.Const;
err_gap = abs(obj_p - obj_d) / (1 + abs(obj_p) + abs(obj_d));

inf_res = inf;
unb_res = inf;

end