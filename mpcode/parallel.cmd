#!/bin/bash 
#SBATCH -N 2 # node count 
#SBATCH --ntasks-per-node=8 
#SBATCH -t 1:00:00 
# sends mail when process begins, and 
# when it ends. Make sure you define your email 
#SBATCH --mail-type=begin 
#SBATCH --mail-type=end 
#SBATCH --mail-user=yourNetID@princeton.edu 

# Load openmpi environment 
module load openmpi 
module load intel

srun ./a.out
