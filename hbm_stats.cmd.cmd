#!/bin/bash 
#SBATCH -N 2 # node count 
#SBATCH --ntasks-per-node=8 
#SBATCH -t 1:00:00 
# sends mail when process begins, and 
# when it ends. Make sure you define your email 
#SBATCH --mail-type=begin 
#SBATCH --mail-type=end 
#SBATCH --mail-user=eboix@princeton.edu 

# Load openmpi environment 
module load openmpi 
module load intel

# Compile the C file
mpicc -o mpi_parallelize mpi_parallelize.c

# The MATLAB file we will be calling to do the jobs is given below.
# Convention: calling "matlab -r matfile(-1)" exports the total number of jobs to EBOIX_JOB_NUM.
# Calling "matlab -r matfile(i)" for i in 1:job_num runs the desired job.
export EBOIX_MAT_CALL="/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r "
matfile='hbm_stats_exec_job'
eval $EBOIX_MAT_CALL $matfile

# Run the jobs.
srun ./mpi_parallelize $matfile $EBOIX_NUM_JOBS
