#!/bin/bash
#SBATCH -N 1  # 1 node
#SBATCH -n 1  # 1 task per node
#SBATCH -c 4 #  4 cores per tasks, means 4 Matlab workers
#SBATCH -o matlab.out # stdout is redirected to that file
#SBATCH -e matlab.err # stderr is redirected to that file
#SBATCH -t 00:01:00 # time required, here it is 1 min
# sends mail when process begins, and
# when it ends. Make sure you define your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
# replace your_netid by your actual netid
#SBATCH --mail-user=your_netid@princeton.edu

srun /usr/licensed/bin/matlab -nodesktop -nosplash -r parfor_test
