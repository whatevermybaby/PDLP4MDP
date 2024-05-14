function [data, work] = normalize_data(work, data, cone)
%  min c'x                 min (E-1c*sc_c)'(Ex*sc_b)
% s.t. Gx >= h            s.t. (D-1GE-1)(Ex*sc_b) >= (D-1h*sc_b)
%      Ax = b       ==>        (D-1AE-1)(Ex*sc_b) = (D-1b*sc_b)
%       x in cone                (Ex*sc_b) in cone

m1 = length(data.h);
m2 = length(data.b);
m = m1 + m2;
n = length(data.c);

min_scale   = 1e-3;
max_scale   = 1e3;
minRowScale = min_scale * sqrt(n);
maxRowScale = max_scale * sqrt(n);
minColScale = min_scale * sqrt(m);
maxColScale = max_scale * sqrt(m);

D_hat = ones(m, 1);
E_hat = ones(n, 1);
sc_b  = 1;
sc_c  = 1;

%% scaling
% ruiz_flag = false;
% l2_flag   = false;
% pc_flag   = false;

ruiz_flag = true;
l2_flag   = true;
pc_flag   = true;

if ruiz_flag
    n_ruiz = 10;
    for k = 1 : n_ruiz
        E1 = sqrt(max(abs(data.G), [], 1))';
        E2 = sqrt(max(abs(data.A), [], 1))';
        
        if isempty(E1)
            E = E2;
        elseif isempty(E2)
            E = E1;
        else
            E = max(E1, E2);
        end
        
        begin_cone = 1;
        end_cone   = -1;
        if isfield(cone,"l")   % R_+^l
            end_cone = begin_cone + cone.f - 1;
            begin_cone = end_cone + 1;
        end

        if isfield(cone,"f")    % R^f
            end_cone = begin_cone + cone.l - 1;
            begin_cone = end_cone + 1;
        end
        
        E(E < minColScale) = 1;
        E(E > maxColScale) = maxColScale;
        E_hat = E .* E_hat;

        D1 = sqrt(max(abs(data.G), [], 2));
        D2 = sqrt(max(abs(data.A), [], 2));
        D = [D1; D2];
        D(D < minRowScale) = 1;
        D(D > maxRowScale) = maxRowScale;
        D_hat = D_hat .* D;

        data.G = spdiags(1./D1, 0, m1, m1) * data.G * spdiags(1./E, 0, n, n);
        data.A = spdiags(1./D2, 0, m2, m2) * data.A * spdiags(1./E, 0, n, n);
    end
end

if l2_flag
    E1 = sqrt(sum((data.G).^2, 1))';
    E2 = sqrt(sum((data.A).^2, 1))';
    if isempty(E1)
        E = sqrt(E2);
    elseif isempty(E2)
        E = sqrt(E1);
    else
        E = sqrt(max(E1, E2));
    end
%      E=sqrt(sqrt(sum(([data.G;data.A]).^2, 1)))';
    
    begin_cone = 1;
    end_cone   = -1;
    if isfield(cone,"l")   % R_+^l
        end_cone = begin_cone + cone.f - 1;
        begin_cone = end_cone + 1;
    end

    if isfield(cone,"f")    % R^f
        end_cone = begin_cone + cone.l - 1;
        begin_cone = end_cone + 1;
    end

    E(E < minColScale) = 1;
    E(E > maxColScale) = maxColScale;
    E_hat = E .* E_hat;
    
%     data.G = data.G * spdiags(1./E, 0, n, n);
%     data.A = data.A * spdiags(1./E, 0, n, n);
    
    D1 = sqrt(sqrt(sum((data.G).^2, 2)));
    D2 = sqrt(sqrt(sum((data.A).^2, 2)));
    D = [D1; D2];
    D(D < minRowScale) = 1;
    D(D > maxRowScale) = maxRowScale;
    D_hat = D_hat .* D;
    
%     data.G = spdiags(1./D1, 0, m1, m1) * data.G;
%     data.A = spdiags(1./D2, 0, m2, m2) * data.A;

    data.G = spdiags(1./D1, 0, m1, m1) * data.G * spdiags(1./E, 0, n, n);
    data.A = spdiags(1./D2, 0, m2, m2) * data.A * spdiags(1./E, 0, n, n);
end

if pc_flag
    alpha_pc = 1;
    E1 = sqrt(sum((abs(data.G)).^alpha_pc, 1).^(1/alpha_pc))';
    E2 = sqrt(sum((abs(data.A)).^alpha_pc, 1).^(1/alpha_pc))';
    if isempty(E1)
        E = sqrt(E2);
    elseif isempty(E2)
        E = sqrt(E1);
    else
        E = sqrt(max(E1, E2));
    end

% E = sqrt(sum((abs([data.G;data.A])).^alpha_pc, 1).^(1/alpha_pc))';


    begin_cone = 1;
    end_cone   = -1;
    if isfield(cone,"l")   % R_+^l
        end_cone = begin_cone + cone.f - 1;
        begin_cone = end_cone + 1;
    end

    if isfield(cone,"f")    % R^f
        end_cone = begin_cone + cone.l - 1;
        begin_cone = end_cone + 1;
    end

    E(E < minColScale) = 1;
    E(E > maxColScale) = maxColScale;
    E_hat = E .* E_hat;
    
    D1 = sqrt(sum((abs(data.G)).^(2-alpha_pc), 2).^(1/(2-alpha_pc)));
    D2 = sqrt(sum((abs(data.A)).^(2-alpha_pc), 2).^(1/(2-alpha_pc)));
    D = [D1; D2];
    D(D < minRowScale) = 1;
    D(D > maxRowScale) = maxRowScale;
    D_hat = D_hat .* D;

    data.G = spdiags(1./D1, 0, m1, m1) * data.G * spdiags(1./E, 0, n, n);
    data.A = spdiags(1./D2, 0, m2, m2) * data.A * spdiags(1./E, 0, n, n);
end

data.c = data.c ./ E_hat;
data.h = data.h ./ D_hat(1:m1);
data.b = data.b ./ D_hat(m1+1:m1+m2);

nm_c = norm(data.c, 2);
nm_h = norm(data.h, 2);
nm_b = norm(data.b, 2);
sc_c = sqrt(nm_c);
sc_b = sqrt(sqrt(nm_h^2 + nm_b^2));

if sc_c < min_scale
    sc_c = 1;
elseif sc_c > max_scale
    sc_c = max_scale;
end

if sc_b < min_scale
    sc_b = 1;
elseif sc_b > max_scale
    sc_b = max_scale;
end

sc_c = 1 / sc_c;
sc_b = 1 / sc_b;
data.c = sc_c * data.c;
data.h = sc_b * data.h;
data.b = sc_b * data.b;

%% record
work.D     = D_hat;
work.E     = E_hat;
work.sc_b  = sc_b;
work.sc_c  = sc_c;

end