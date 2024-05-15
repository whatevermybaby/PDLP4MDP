import numpy as np
from pymdptoolbox.src.mdptoolbox import *
from pymdptoolbox.src.mdptoolbox import example
import pandas as pd
import cvxpy as cp
import argparse
import datetime
import sys
# import chardet
from mazemdp import create_random_maze
# print(cp.installed_solvers())

def get_iter(path):
    with open(path, "r",encoding='UTF-16') as file:
        text = file.read()

# 按行分割文本
        lines = text.strip().split('\n')

# 查找包含 "Final solution stats" 的行
        for line in lines:
            if "Final solution stats" in line:
                # 获取目标行索引
                index = lines.index(line)
                # 提取目标行
                target_line = lines[index + 2]  # 第三行的索引是当前行索引 + 2
                # 使用空格分割行，并获取第一个元素
                data = target_line.split()[0]
                print(data)
                break
        else:
            print("No match found.")
    return int(data)

# 定义一个函数，将逗号分隔的字符串转换为整数数组
def parse_array(s):
    return [int(x) for x in s.split(',')]
def post_operate_data(solution,real_sol,results=[],name='None',discount=0.9):
    '''对已经得到的解做一些后处理方便展示'''
    # 找到不同的分量的位置
    different_positions_cvx = np.where(np.array(solution.policy) != np.array(real_sol.policy))[0]

    # 找到不同的分量的个数
    num_different_elements_cvx = len(different_positions_cvx)

    # 计算 rvi.value 与 RVI.value 的差值的平均值
    value_diff_cvx = np.mean(np.abs(np.array(solution.V) - np.array(real_sol.V)))

    # 将结果加入到字典中
    if discount==1:
        results[name] = {"Time": solution.time,
                        "iteration": solution.iter,
                        "Wrong_Elements_Count": num_different_elements_cvx,
                        "Value_Difference_Avg": value_diff_cvx,
                        "span":np.max(solution.V)-np.min(solution.V),
                        "Average_Reward":solution.average_reward}
    else:
        results[name] = {"Time": solution.time,
                        "iteration": solution.iter,
                        "Wrong_Elements_Count": num_different_elements_cvx,
                        "Value_Difference_Avg": value_diff_cvx,
                        "span":np.max(solution.V)-np.min(solution.V)}

# # Compute the spectral radius
    # eigenvalues = np.linalg.eigvals(P)
    # spectral_radius = max(abs(eigenvalues))
    # print(spectral_radius)        

def main(args):
    # 存储结果的字典
    results = {}
    if args.problem_type=='forest':
        P, R = example.forest(args.problem_size[0])
    elif args.problem_type=='random':
        P, R = example.rand(args.problem_size[0],args.problem_size[1])
    elif args.problem_type=='maze':
        mdp_maze, nb_states,coord_x, coord_y = create_random_maze(args.problem_size[0],args.problem_size[1], args.wall_ratio)
        P=np.transpose(mdp_maze.P,(1,0,2))
        R=mdp_maze.r
        
    # # a feasible discounted example
    # P = np.zeros((2, 3, 3))
    # P[0, 0, 0] = 0.2;P[0, 0, 1] = 0.8;P[0, 1, 0] = 0.8;P[0, 1, 1] = 0.2;P[0, 2, 2] = 1
    # P[1, 0, 0] =0.9; P[1, 0, 2] =0.1; P[1, 1, 0] =0.9; P[1, 1, 2] =0.1; P[1, 2, 2] =1
    # # Definition of Reward matrix
    # R = np.zeros((3, 2))
    # R[0, 0] = -1;R[1, 0] = -2;R[2, 0] = 0
    # R[0, 1] = -1;R[1, 1] = -2;R[2, 1] = 0
    
    # Parameter of pdhg
    discount=args.discount; eps=args.eps

    # Policy Iteration
    pi = mdp.PolicyIteration(P, R, discount)
    pi.run()
   
    # Value Iteration
    vi = mdp.ValueIteration(P, R, discount, eps)
    vi.run()
    
    #PDLP
    pdlp=mdp.PDLP_pk(P,R,discount)
    pdlp.run()
    # pdlp.iter=get_iter(f'./error/PDLP_{args.problem_type}_{args.problem_size[0]}_{args.problem_size[1]}_error.txt')
    
    
    if args.problem_type=='maze':
        post_operate_data(pi,pi,results,f"PI_{args.problem_type}_{args.problem_size[0]*args.problem_size[1]*(1-args.wall_ratio)}_{4}_{args.discount}_{args.wall_ratio}",args.discount)
        post_operate_data(vi,pi,results,f"VI_{args.problem_type}_{args.problem_size[0]*args.problem_size[1]*(1-args.wall_ratio)}_{4}_{args.discount}_{args.wall_ratio}",args.discount)
        post_operate_data(pdlp,pi,results,f"PDLP_{args.problem_type}_{args.problem_size[0]*args.problem_size[1]*(1-args.wall_ratio)}_{4}_{args.discount}_{args.wall_ratio}",args.discount)
    else:
        post_operate_data(pi,pi,results,f"PI_{args.problem_type}_{args.problem_size[0]}_{args.problem_size[1]}_{args.discount}",discount)
        post_operate_data(vi,pi,results,f"VI_{args.problem_type}_{args.problem_size[0]}_{args.problem_size[1]}_{args.discount}",discount)
        post_operate_data(pdlp,pi,results,f"PDLP_{args.problem_type}_{args.problem_size[0]}_{args.problem_size[1]}_{args.discount}",discount)
    
    ## store the results
    df = pd.DataFrame(results).T
    print(df)
    # Specify the file path where you want to save the CSV file
    file_path = './results/file_test.csv'
    # Save the DataFrame to a CSV file
    # df.to_csv(file_path, index=False)
    df.to_csv(file_path,mode='a', header=True,index=True)
    
    
 
 
 
 
    

    
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    # Add arguments
    parser.add_argument('--problem_type', type=str, default='forest', help='the type of problem')
    parser.add_argument('--problem_size', type=parse_array, default=[100,20], help='size of problem')
    parser.add_argument('--discount', type=float, default=0.99, help='discount of MDP')
    parser.add_argument('--eps', type=float, default=1e-6, help='solution accuracy')
    parser.add_argument('--wall_ratio', type=float, default=0.2, help='the ratio of wall in maze')
    # parser.add_argument('--learning_rate', type=float, default=0.0003, help='learning rate')

    args = parser.parse_args()

    main(args)

