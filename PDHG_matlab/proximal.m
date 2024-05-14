function [z, z_1] = proximal(z, q, cone, lambda)
% proximal problem
%  min - mu*f(z) + 1/(2*lambda)*||z - (zk - lambda * q)||^2
% s.t. z in cone

z_1 = z;

begin_cone = 1;
end_cone   = -1;

if isfield(cone,"l")    % R_+^l
    end_cone = begin_cone + cone.l - 1;
    temp = z(begin_cone:end_cone) - lambda * q(begin_cone:end_cone);
    z(begin_cone:end_cone) = (temp>=0).*temp;
    begin_cone = end_cone + 1;
end

if isfield(cone,"f")    % R^f
    end_cone = begin_cone + cone.f - 1;
    z(begin_cone:end_cone) = z(begin_cone:end_cone) - lambda * q(begin_cone:end_cone);
    begin_cone = end_cone + 1;
end

end