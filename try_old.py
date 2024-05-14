from cvxopt import matrix, solvers
import re

# # 读取文件内容
# with open('./output_file.txt', 'r',encoding='latin-1') as file:
#     content = file.read()

# # 使用正则表达式提取 iter* 的值
# # iter_matches = re.findall(r'iter#\s*(\d+)', content)
# matches = re.findall(r'(\d+)\s+[.\d]+\s+\d+\.\d\s+\|\s+[\d.e+-]+\s+[\d.e+-]+\s+[\d.e+-]+\s+\|\s+[\d.e+-]+\s+[\d.e+-]+\s+\|', content)

# # 如果有多个匹配，取最后一个作为最终结果
# final_iter = matches[-1]

# print("Final iteration value:", final_iter)
import re

import chardet

# # 读取文件内容并检测编码
# with open("output_file.txt", "rb") as file:
#     raw_data = file.read()
#     result = chardet.detect(raw_data)

# # 打印检测结果
# print("Detected encoding:", result['encoding'])

# 打开文件并读取文本
with open("output_file.txt", "r",encoding='UTF-16') as file:
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

# # 文本
# text = """
# Final solution stats:
#  iter# kkt_pass   time | rel_prim_res rel_dual_res      rel_gap |   prim_resid   dual_resid      obj_gap |     prim_obj     dual_obj |  prim_var_l2  dual_var_l2
#   5120   5220.0    0.0 |      0.00000  1.49710e-07  4.97586e-07 |      0.00000  6.23135e-07   0.00150947 |      1516.29      1516.29 |      480.088      435.133
# """

# # 按行分割文本
# lines = text.strip().split('\n')

# # 查找包含 "Final solution stats" 的行
# for line in lines:
#     if "Final solution stats" in line:
#         # 获取目标行索引
#         index = lines.index(line)
#         # 提取目标行
#         target_line = lines[index + 2]  # 第三行的索引是当前行索引 + 2
#         # 使用空格分割行，并获取第一个元素
#         data = target_line.split()[0]
#         print("Data at position (3, 1):", data)
#         break
# else:
#     print("No match found.")




# A = matrix([ [-1.0, -1.0, 0.0, 1.0], [1.0, -1.0, -1.0, -2.0] ])
# b = matrix([ 1.0, -2.0, 0.0, 4.0 ])
# c = matrix([ 2.0, 1.0 ])
# sol=solvers.lp(c,A,b)
# print(sol['x'])

    # # rvi.run()
    # # ## True solution:
    # # lp_cvx=mdp._LP_cplex(P,R,discount,eps)
    # # lp_cvx.run()
    # # # 找到不同的分量的位置
    # # different_positions_cvx = np.where(np.array(lp_cvx.policy) != np.array(lp_cvx.policy))[0]

    # # # 找到不同的分量的个数
    # # num_different_elements_cvx = len(different_positions_cvx)

    # # # 计算 rvi.value 与 RVI.value 的差值的平均值
    # # value_diff_cvx = np.mean(np.abs(np.array(lp_cvx.V) - np.array(lp_cvx.V)))

    # # # 将结果加入到字典中
    # # results["CVX"] = {"Time": lp_cvx.time,
    # #                 "iteration": lp_cvx.iter,
    # #                 "Wrong_Elements_Count": num_different_elements_cvx,
    # #                 "Value_Difference_Avg": value_diff_cvx,
    # #                 "span":np.max(lp_cvx.V)-np.min(lp_cvx.V),
    # #                 "Average_Reward":lp_cvx.average_reward}

    # # Relative VI
    # # rvi = mdp.RelativeValueIteration(P, R,eps)
    # # rvi.run()

    # # # 找到不同的分量的位置
    # # different_positions_rvi = np.where(np.array(rvi.policy) != np.array(lp_cvx.policy))[0]

    # # # 找到不同的分量的个数
    # # num_different_elements_rvi = len(different_positions_rvi)

    # # # 计算 rvi.value 与 RVI.value 的差值的平均值
    # # value_diff_rvi = np.mean(np.abs(np.array(rvi.V) - np.array(lp_cvx.V)))

    # # # 将结果加入到字典中
    # # results["RVI"] = {"Time": rvi.time,
    # #                 "iteration": rvi.iter,
    # #                 "Wrong_Elements_Count": num_different_elements_rvi,
    # #                 "Value_Difference_Avg": value_diff_rvi,
    # #                 "span":np.max(rvi.V)-np.min(rvi.V),
    # #                 "Average_Reward":rvi.average_reward}

    # #  #LP solver
    # # lp=mdp._LP(P,R,discount)
    # # lp.run()
    # # # 找到不同的分量的位置
    # # different_positions_lp = np.where(np.array(lp_cvx.policy) != np.array(lp.policy))[0]

    # # # 找到不同的分量的个数
    # # num_different_elements_lp = len(different_positions_lp)

    # # # 计算 lp.value 与 LP.value 的差值的平均值
    # # value_diff_lp = np.mean(np.abs(np.array(lp.V) - np.array(lp_cvx.V)))

    # # # 将结果加入到字典中
    # # results["LP_cvxopt"] = {"Time": lp.time,
    # #                  "iteration": lp.iter,
    # #                  "Wrong_Elements_Count": num_different_elements_lp,
    # #                  "Value_Difference_Avg": value_diff_lp,
    # #                  "Average_Reward":lp.average_reward}

    # ## no-restart pdhg
    # lp_non = mdp.PDLP(P, R, discount,eps)
    # true_span=np.max(lp_cvx.V)-np.min(lp_cvx.V)
    # # lp_non.run(max_iter, lr,  true_span, restart='None')
    # lp_non.run(max_iter, lr,  lp_cvx.average_reward, restart='None')

    # # 找到不同的分量的位置
    # different_positions_non = np.where(np.array(lp_cvx.policy) != np.array(lp_non.policy))[0]

    # # 找到不同的分量的个数
    # num_different_elements_non = len(different_positions_non)

    # # 计算 pi.value 与 PDLP_non.value 的差值的平均值
    # value_diff_non = np.mean(np.abs(np.array(lp_cvx.V) - np.array(lp_non.V)))

    # # 将结果加入到字典中
    # results["PDLP_non"] = {"Time": lp_non.time,
    #                     "iteration": lp_non.iter,
    #                     "Wrong_Elements_Count": num_different_elements_non,
    #                     "Value_Difference_Avg": value_diff_non,
    #                     "span":np.max(lp_non.V)-np.min(lp_non.V),
    #                     "Average_Reward":lp_non.average_reward}
    # print(lp_cvx.policy)
    # print(lp_non.policy)

    # pdlp=mdp.PDLP_pk(P,R,discount,eps)
    # pdlp.run()
    # # 找到不同的分量的位置
    # different_positions_pdlp = np.where(np.array(pdlp.policy) != np.array(lp_cvx.policy))[0]

    # # 找到不同的分量的个数
    # num_different_elements_pdlp = len(different_positions_pdlp)

    # # 计算 rvi.value 与 RVI.value 的差值的平均值
    # value_diff_pdlp = np.mean(np.abs(np.array(pdlp.V) - np.array(lp_cvx.V)))

    # # 将结果加入到字典中
    # results["PDLP_pk"] = {"Time": pdlp.time,
    #                 "iteration": pdlp.iter,
    #                 "Wrong_Elements_Count": num_different_elements_pdlp,
    #                 "Value_Difference_Avg": value_diff_pdlp,
    #                 "span":np.max(lp_cvx.V)-np.min(lp_cvx.V),
    #                 "Average_Reward":pdlp.average_reward}

    


    # # Value Iteration
    # # vi = mdp.ValueIteration(P, R, discount)
    # # vi.run(3)

    # # # 找到不同的分量的位置
    # # different_positions_vi = np.where(np.array(pi.policy) != np.array(vi.policy))[0]

    # # # 找到不同的分量的个数
    # # num_different_elements_vi = len(different_positions_vi)

    # # # 计算 pi.value 与 VI.value 的差值的平均值
    # # value_diff_vi = np.mean(np.abs(np.array(pi.V) - np.array(vi.V)))

    # # 将结果加入到字典中
    # # results["VI"] = {"Time": vi.time,
    # #                  "iteration": vi.iter,
    # #                  "Wrong_Elements_Count": num_different_elements_vi,
    # #                  "Value_Difference_Avg": value_diff_vi}
    # # print(vi.iter)
    # # print(vi.V)


    # #
    # # V=3


    # # # PDLP_fix_restart
    # # lp_fix = mdp.PDLP(P, R, discount)
    # # lp_fix.run(100000, 0.1, V,restart='fixed')

    # # # 找到不同的分量的位置
    # # different_positions_fix = np.where(np.array(pi.policy) != np.array(lp_fix.policy))[0]

    # # # 找到不同的分量的个数
    # # num_different_elements_fix = len(different_positions_fix)

    # # # 计算 pi.value 与 PDLP_fix.value 的差值的平均值
    # # value_diff_fix = np.mean(np.abs(np.array(pi.V) - np.array(lp_fix.V)))

    # # # 将结果加入到字典中
    # # results["PDLP_fix"] = {"Time": lp_fix.time,
    # #                        "iteration": lp_fix.iter,
    # #                        "Wrong_Elements_Count": num_different_elements_fix,
    # #                        "Value_Difference_Avg": value_diff_fix}

    # # # PDLP_adapt_restart
    # # lp_adapt = mdp.PDLP(P, R, 0.9)
    # # lp_adapt.run(100000, 0.05, pi.V,restart='adapt')

    # # # 找到不同的分量的位置
    # # different_positions_adapt = np.where(np.array(pi.policy) != np.array(lp_adapt.policy))[0]

    # # # 找到不同的分量的个数
    # # num_different_elements_adapt = len(different_positions_adapt)

    # # # 计算 pi.value 与 PDLP_fix.value 的差值的平均值
    # # value_diff_adapt = np.mean(np.abs(np.array(pi.V) - np.array(lp_adapt.V)))

    # # # 将结果加入到字典中
    # # results["PDLP_adapt"] = {"Time": lp_adapt.time,
    # #                        "Different_Positions": different_positions_adapt,
    # #                        "Wrong_Elements_Count": num_different_elements_adapt,
    # #                        "Value_Difference_Avg": value_diff_adapt}
    # # # 将结果转换为 DataFrame

    # # import numpy, mdptoolbox
    # # P = np.array((((0.5, 0.5), (0.8, 0.2)), ((0, 1), (0.1, 0.9))))
    # # R = np.array(((5, 10), (-1, 2)))
    # # print(P)
    # # print(R)
    # # vi = mdp.ValueIteration(P, R, 0.9)
    # # vi.run()
    # # vi.policy # result is (0, 0, 0)
    # # print(vi.policy)
    # # lp = mdp.PDLP(P, R, 0.9)
    # # lp.run()
    # # print(lp.policy) #FIXME: gives (1, 1), should be (1, 0)