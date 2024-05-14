function [x, x_1, y, eta, eta_prime] = adaptive_step_size(data, cone, cone_y, x, y, eta_hat, w, alpha, k)

m1 = length(data.h);
m2 = length(data.b);

eta = eta_hat;

while true
    
    assert(eta > 0);
    
    % primal update
    grad_x = data.c - data.G' * y(1:m1) - data.A' * y(m1+1:m1+m2);
    [x_prime, x_prime_1] = proximal(x, grad_x, cone, eta / w);

    % dual update
    x_hat = alpha*x_prime+(1-alpha)*x_prime_1;
    grad_y_neg = [data.G*x_hat-data.h;
              data.A*x_hat-data.b];
    [y_prime, ~] = proximal(y, grad_y_neg, cone_y, eta * w);
    
    delta_x = x_prime - x;
    delta_y = y_prime - y;
    eta_bar = norm_w(delta_x, delta_y, w)^2 / ...
              abs(2 * (delta_y(1:m1)' * data.G * delta_x + delta_y(m1+1:m1+m2)' * data.A * delta_x));
    eta_prime = min((1 - (k+1)^(-0.3))*eta_bar, (1 + (k+1)^(-0.6))*eta);
    
    if eta <= eta_bar
        break;
    else
        eta = eta_prime;
    end
end

x   = x_prime;
x_1 = x_prime_1;
y   = y_prime;

end