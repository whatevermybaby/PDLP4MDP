%% load data
clear;
warning off;

root = '.\';
%solverpath = [root,'PDIP'];
addpath(root);
%addpath(solverpath);


datapath = '.\mps\';
datasets = dir(fullfile(datapath, "*.mps"));

%% setting

output_flag = true;

n_prob = length(datasets);
err = 1e-4;
max_time = 600;
%problem_set = 1:2;
problem_set = [10];

diaryname = [root, 'test\netlib_err_', num2str(err,"%.2e"), '_300s_', date(), '.txt'];
filename = [root, 'test\netlib_err_', num2str(err,"%.2e"), '_300s_', date(), '.csv'];
filetitle = ["Id","Problem","m1","m2","n","eps", "GRB obj", ...
             "pdhg time","pdhg iter","pdhg obj_p", "pdhg stat"];
format = ["%d","%s","%d","%d","%d","%.1e","%f", ...
          "%f","%d","%f","%s"];
results_file = struct();

%% solve

count_pdhg = 0;

if output_flag
    diary(diaryname);
    diary on;
end

for i = problem_set
    %% get problem
    problem_name = strrep(datasets(i).name,'.mps','');
    fprintf("Problem %d: %s\n", i, problem_name);
    
    prob_grb = gurobi_read([datapath,datasets(i).name]);
    res_grb = gurobi(prob_grb);
    
    data = mpsread([datapath, datasets(i).name]);
    if ~isfield(prob_grb,'objcon')
        data.Const = 0;
    else
        data.Const = prob_grb.objcon;
    end
    [prob, cone, ind_le, ind_nneg, ind_free] = reformulate_lp(data);
    
    %% Parameter set

    params = struct();
    params.max_time = max_time;
    params.eps_p = err;
    params.eps_d = err;
    params.eps_gap = err;
    params.restart = true;
    params.rst_max = 1000; % max restart number
    params.normalize = true;
    params.ada_pri_w = false;% adaptive primal dual weight
    params.ada_stepsize = false;% adaptive stepsize
%    params.eta = 0.1;
%    params.w = 1;
    params.verbose = true;

    %% PDHG

    [sol_pdhg, info_pdhg] = pdhg(prob, cone, params);
    x = zeros(length(sol_pdhg.x), 1);
    x(ind_nneg) = sol_pdhg.x(1:cone.l);
    x(ind_free) = sol_pdhg.x(cone.l+1:end);
    sol_pdhg.x = x;
    sol_pdhg.x(ind_le) = -sol_pdhg.x(ind_le);
    sol_pdhg.x(ind_le) = sol_pdhg.x(ind_le) + data.ub(ind_le);
    ind_lb = setdiff(ind_nneg, ind_le);
    sol_pdhg.x(ind_lb) = sol_pdhg.x(ind_lb) + data.lb(ind_lb);
    if info_pdhg.status == "Solved"
        count_pdhg = count_pdhg + 1;
    end

    %% result

    fprintf("\nIter: PDHG %d \n", info_pdhg.iter);
    fprintf("Obj: PDHG %+.8e", info_pdhg.obj_p);
    fprintf("\n");
    
    results_file(i).id        = i;
    results_file(i).problem   = problem_name;
    results_file(i).m1        = size(prob.G,1);
    results_file(i).m2        = size(prob.A,1);
    results_file(i).n         = size(prob.c,1);
    results_file(i).eps       = err;
    results_file(i).obj_grb   = res_grb.objval;
    
    results_file(i).pdhg_time = info_pdhg.runtime;
    results_file(i).pdhg_iter = info_pdhg.iter;
    results_file(i).pdhg_obj_p = info_pdhg.obj_p;
    results_file(i).pdhg_stat = info_pdhg.status;

    
    if output_flag
        write1struct2csv(filename, filetitle, results_file(i), format);
    end
end

fprintf("\nSolved: PDHG %d.\n", count_pdhg);

if output_flag
    diary off;
end