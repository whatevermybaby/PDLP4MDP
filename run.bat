@echo off
@REM python main.py --problem_size 100,2 --discount 0.99 > outputfile1.txt 2>&1
@REM python main.py --problem_size 500,2 --discount 0.99 > outputfile2.txt 2>&1
@REM python main.py --problem_size 1000,2 --discount 0.99 > outputfile3.txt 2>&1
@REM python main.py --problem_size 10000,2 --discount 0.99 > outputfile4.txt 2>&1

python main.py --problem_size 1000,2 --discount 0.9 > outputfile5.txt 2>&1
python main.py --problem_size 1000,2 --discount 0.995 > outputfile6.txt 2>&1

python main.py --problem_size 1000,2 --discount 0.999 > outputfile7.txt 2>&1

python main.py --problem_size 1000,2 --discount 0.5 > outputfile8.txt 2>&1