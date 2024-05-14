import os
from typing import Tuple, List

import numpy as np
import matplotlib.pyplot as plt

from mazemdp.maze_plotter import show_videos
from mazemdp.mdp import Mdp


from mazemdp import create_random_maze

mdp, nb_states,coord_x, coord_y = create_random_maze(20, 10, 0.1)


# print("第一个子数组的第一个行的所有列的和为:", sum_column)
print(mdp.r.shape)