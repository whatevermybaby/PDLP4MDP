import random

def generate_random_number(minimum, maximum):
    """
    生成指定范围内的随机整数
    参数：
        minimum: 随机数范围的最小值
        maximum: 随机数范围的最大值
    返回值：
        随机生成的整数
    """
    return random.randint(minimum, maximum)

# 示例用法
min_value = 1
max_value = 100
random_number = generate_random_number(min_value, max_value)
print("随机数:", random_number)
