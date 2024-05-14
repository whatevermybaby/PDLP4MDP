function status = check_status(numerical, solved, infeasible, unbounded, timeout)

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

end