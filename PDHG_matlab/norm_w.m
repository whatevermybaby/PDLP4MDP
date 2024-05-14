function nrm_w = norm_w(x, y, w)

nrm_w = sqrt(w * norm(x)^2 + norm(y)^2 / w);

end