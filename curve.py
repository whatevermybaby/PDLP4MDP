import numpy as np
from scipy.optimize import curve_fit
import pandas as pd
import matplotlib.pyplot as plt

# 读取CSV文件
file_path = 'D:/xch2024/pdlp for mdp/diminput_32_2024.01.31_00.01.00.csv'
data = pd.read_csv(file_path)

# 提取x和y列的数据
x_data = data['Step'].values
y_data = data['Value'].values

# 定义拟合模型函数
def model_function(x, K, c):
    return K * np.sqrt(x) + c

# 使用curve_fit拟合数据
params, covariance = curve_fit(model_function, x_data, y_data)

# 提取拟合参数
K_fit, c_fit = params

# 生成拟合后的y值
y_fit = model_function(x_data, K_fit, c_fit)

# 打印拟合参数
print("拟合参数 K:", K_fit)
print("拟合参数 c:", c_fit)

# 绘制原始数据和拟合曲线
plt.scatter(x_data, y_data, label='latent=8,input =16')
plt.plot(x_data, y_fit, label='curve', color='red')
equation_text = f'y = {K_fit:.2f} * sqrt(x) + {c_fit:.2f}'
plt.text(0.5, 0.5, equation_text, fontsize=12, transform=plt.gca().transAxes)
plt.xlabel('Step')
plt.ylabel('regret')
plt.legend()
plt.show()
