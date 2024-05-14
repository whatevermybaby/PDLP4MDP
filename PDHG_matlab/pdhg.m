function [sol, info] = pdhg(data, cone, params)
% ------------------------------------------
% min  c'x
% s.t. Gx >= h     (y1 >= 0)
%      Ax = b      (y2 free)
%       x in R+ * R
% 
% L = c'x - y1'(Gx - h) - y2'(Ax - b)
% 
% data: c, G, A, h, b, Const (optional)
% cone: l, f
% ------------------------------------------

%% start timer
tic;

%% default settings
max_iter     = 1e8;
max_time     = inf;
eps_p        = 1e-3;
eps_d        = 1e-3;
eps_gap      = 1e-3;
eps_inf      = 1e-5;
eps_unb      = 1e-5;
alpha        = 2.0; % over-relaxation
normalize    = true;
verbose      = true;
eta          = 0.001;
restart      = true;
rst_max      = 1000;
rst_len      = 0; % not param, only for initialize
w            = 1; % primal stepsize eta / w, dual stepsize eta * w
ada_pri_w    = false;
ada_stepsize = false;
theta        = 0.5; % theta in adaptive primal weight
timeout      = false;

%% constants
undet_tol    = 1e-18;             % tol for undetermined solution (tau = kappa = 0)

%% parameter setting
if nargin == 3
    if isfield(params,'max_iter');       max_iter      = params.max_iter;       end
    if isfield(params,'max_time');       max_time      = params.max_time;       end
    if isfield(params,'eps_p');          eps_p         = params.eps_p;          end
    if isfield(params,'eps_d');          eps_d         = params.eps_d;          end
    if isfield(params,'eps_gap');        eps_gap       = params.eps_gap;        end
    if isfield(params,'eps_inf');        eps_inf       = params.eps_inf;        end
    if isfield(params,'eps_unb');        eps_unb       = params.eps_unb;        end
    if isfield(params,'alpha');          alpha         = params.alpha;          end
    if isfield(params,'normalize');      normalize     = params.normalize;      end
    if isfield(params,'verbose');        verbose       = params.verbose;        end
    if isfield(params,'eta');            eta           = params.eta;            end
    if isfield(params,'w');              w             = params.w;              end
    if isfield(params,'restart');        restart       = params.restart;        end
    if isfield(params,'rst_max');        rst_max       = params.rst_max;        end
    if isfield(params,'ada_pri_w');      ada_pri_w     = params.ada_pri_w;      end
    if isfield(params,'theta');          theta         = params.theta;          end
    if isfield(params,'ada_stepsize');   ada_stepsize  = params.ada_stepsize;   end
end

if verbose
    fprintf("PDHG.\n");
    fprintf("\neps_p = %.1e, eps_d = %.1e, eps_gap = %.1e\n", eps_p, eps_d, eps_gap);
end

%% data setting
% const term
if ~isfield(data,'Const')
    data.Const     = 0;
end

if verbose
    fprintf("\nConst term = %.7e\n", data.Const);
end

%% pre-calculation

m1 = length(data.h);
m2 = length(data.b);
m = m1 + m2;
n = length(data.c);

cone_y = struct();
cone_y.l = m1;
cone_y.f = m2;

work = struct();

%% data normalization
work.nm_c = norm(data.c, 'inf');
work.nm_h = norm(data.h, 'inf');
work.nm_b = norm(data.b, 'inf');

if normalize
    [data, work] = normalize_data(work, data, cone);
else
    work.D     = ones(m, 1);
    work.E     = ones(n, 1);
    work.sc_b  = 1;
    work.sc_c  = 1;
end

if nargin == 3
    % initial stepsize eta
    if isfield(params,'eta')
        eta          = params.eta;
    else
        eta          = 0.9 / normest([data.G; data.A], 1e-5);
    end
    
    eta_hat = eta;
    
    % initial primal weight w
    if isfield(params,'w')
        w            = params.w;
    else
        w            = initial_primal_weight(data);
    end
end

%% initial point
x = zeros(n, 1);
y = zeros(m, 1);

% init x
begin_cone = 1;
end_cone   = -1;
ind_nneg = false(n, 1);
if isfield(cone,"l")    % R_+^l
    end_cone = begin_cone + cone.l - 1;
    x(begin_cone:end_cone) = ones(cone.l, 1);
    ind_nneg(begin_cone:end_cone) = true;
    begin_cone = end_cone + 1;
end

if isfield(cone,"f")    % R^f
    end_cone = begin_cone + cone.f - 1;
    begin_cone = end_cone + 1;
end

% init y
y(1:m1) = ones(m1, 1);

% record x
x_1 = x;

% for adaptive primal weight
if ada_pri_w
    x0 = x;
    y0 = y;
end

%% main algorithm

line = '----------------------------------------------------------------------------------------------------------';
if verbose
    fprintf('\n%s\n', line);
    fprintf('|  iter  |   mu   |     p_obj     |     d_obj     |     pres     |     dres     |     dgap     |   time  |\n');
    fprintf('%s\n', line);
end

for k = 1:max_iter
    if ada_stepsize
        [x, x_1, y, eta, eta_hat] = adaptive_step_size(data, cone, cone_y, x, y, eta_hat, w, alpha, k);
    else
        % primal update
        grad_x = data.c - data.G' * y(1:m1) - data.A' * y(m1+1:m1+m2);
        [x, x_1] = proximal(x, grad_x, cone, eta / w);
        % dual update
        x_hat = alpha*x+(1-alpha)*x_1;
        grad_y_neg = [data.G*x_hat-data.h;
                  data.A*x_hat-data.b];
        [y, ~] = proximal(y, grad_y_neg, cone_y, eta * w);
    end
    
    % check optimality
    [err_p, err_d, err_gap, obj_p, obj_d, inf_res, unb_res] = convergence_check(work, data, x, y, ind_nneg);
    
    ttime = toc;
    
    if verbose
        fprintf('| %6d |%3.2e|%+3.8e|%+3.8e|%3.8e|%3.8e|%3.8e|%3.2es|\n', ...
               k, 0, obj_p, obj_d, err_p, err_d, err_gap, ttime);
    end
    timeout = ttime > max_time;
    err_ratio = max([err_p/eps_p, err_d/eps_d, err_gap/eps_gap]);
    solved = err_ratio < 1;
    infeasible = inf_res < eps_inf;
    unbounded = unb_res < eps_unb;
    numerical = sum(isnan([err_p, err_d, err_gap])) > 0;
    
    if (solved || infeasible || unbounded || timeout || numerical)
        break;
    end
    
    % restart
    if restart
        if rst_len == 0
            x_avg = x;
            y_avg = y;
            rst_len = 1;
        else
            x_avg = rst_len / (rst_len + 1) * x_avg + 1 / (rst_len + 1) * x;
            y_avg = rst_len / (rst_len + 1) * y_avg + 1 / (rst_len + 1) * y;
            rst_len = rst_len + 1;
        end
        
        rst_flag = whether_restart(rst_len, rst_max, x, y, x_avg, y_avg);
        if rst_flag
            x = x_avg;
            y = y_avg;
            rst_len = 0;
        end
    end
    
    % adaptive primal weight
    if ada_pri_w
        if mod(k, rst_max) == 0
            w = adaptive_primal_weight(w, theta, x, y, x0, y0);
            x0 = x;
            y0 = y;
        end
    end

end

runtime = toc;

if verbose
    fprintf('%s\n', line);
end

%% record and output

obj_p = (data.c' * x) / (work.sc_c * work.sc_b) + data.Const;

if (normalize)
    x = x ./ (work.E * work.sc_b);
    y = y ./ (work.D * work.sc_c);
end

if numerical
    status = 'Numerical error';
elseif solved
    status = 'Solved';
elseif infeasible
    status = 'Infeasible';
elseif unbounded
    status = 'Unbounded';
elseif timeout
    status = 'Unsolved (reach max time limit)';
else
    status = 'Unsolved (reach max iter limit)';
end

sol = struct();
sol.x = x;
sol.y = y;

info = struct();
info.status  = status;
info.obj_p = obj_p; 
info.iter    = k;

info.resPri  = err_p;
info.resDual = err_d;
info.relGap  = err_gap;
info.runtime = runtime;

if verbose
    fprintf("\nTotal solving time: %3.2f seconds.", runtime);

    if status == "Solved"
        fprintf("\nStatus: %s. Objective value of LP: %3.8e.\n\n", status, info.obj_p);
    else
        fprintf("\nStatus: %s.\n\n", status);
    end
end

end