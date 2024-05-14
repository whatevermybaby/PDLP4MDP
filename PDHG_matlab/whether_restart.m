function [rst_flag] = whether_restart(rst_len, rst_max, x, y, x_avg, y_avg)
    rst_flag = false;
    if rst_len >= rst_max
        rst_flag = true;
    end
end