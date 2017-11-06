#!/bin/bash 
# #SBATCH -N 4 # node count 
# #SBATCH --ntasks-per-node=4
#SBATCH -N 1
#SBATCH --ntasks-per-node=20
# #SBATCH --gres=gpu:1
#SBATCH -t 4:00:00 
# sends mail when process begins, and 
# when it ends. Make sure you define your email 
#SBATCH --mail-type=begin 
#SBATCH --mail-type=end 
#SBATCH --mail-user=eboix@princeton.edu


# Load openmpi environment 
module load openmpi 
module load intel

# Run the jobs.
srun ./mpi_parallelize $1 $2 $3 
