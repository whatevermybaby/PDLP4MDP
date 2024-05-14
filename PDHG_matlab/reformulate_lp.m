function [prob, cone, ind_le, ind_nneg, ind_free] = reformulate_lp(data)

%% reformulate
%  min c'x                         min c'x
% s.t. A1x <= b1                  s.t. Gx >= h
%      A2x = b2        ==>             Ax = b
%    lb <= x <= ub                      x in R+ * R

if ~isfield(data,'Const')
    data.Const     = 0;
end

n = length(data.f);

ind_all = 1:n;
ind_all = ind_all';
ind_lb = find(data.lb > -inf);
ind_ub = find(data.ub < inf);
ind_box = intersect(ind_lb, ind_ub);
ind_ge = setdiff(ind_lb, ind_box);
ind_le = setdiff(ind_ub, ind_box);
ind_nneg = union(ind_lb, ind_ub);
ind_free = setdiff(ind_all, ind_nneg);

n_box = length(ind_box);
lb = data.lb;
ub = data.ub;
c = data.f;
G = [-data.Aineq;
     sparse(1:n_box, ind_box, -ones(n_box,1), n_box, n)];
A = data.Aeq;
h = [-data.bineq;
     -ub(ind_box)];
b = data.beq;

Const = data.Const + c(ind_ge)' * lb(ind_ge) + c(ind_le)' * ub(ind_le) + c(ind_box)' * lb(ind_box);
h = h - G(:, ind_ge) * lb(ind_ge) - G(:, ind_le) * ub(ind_le) - G(:, ind_box) * lb(ind_box);
b = b - A(:, ind_ge) * lb(ind_ge) - A(:, ind_le) * ub(ind_le) - A(:, ind_box) * lb(ind_box);

c(ind_le) = -c(ind_le);
G(:, ind_le) = -G(:, ind_le);
A(:, ind_le) = -A(:, ind_le);

c = [c(ind_nneg); c(ind_free)];
G = [G(:, ind_nneg), G(:, ind_free)];
A = [A(:, ind_nneg), A(:, ind_free)];

%% record

cone = struct();
cone.l = length(ind_nneg);
cone.f = length(ind_free);

prob = struct();
prob.c = c;
prob.G = G;
prob.A = A;
prob.h = h;
prob.b = b;
prob.Const = Const;

end