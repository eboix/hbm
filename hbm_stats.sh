#!/bin/bash

# Load openmpi environment 
module load openmpi 
module load intel

# Compile the C file
make

# The MATLAB file we will be calling to do the jobs is given below.
# Convention: calling "matlab -r matfile(-1, job_config)" exports the total number of jobs to EBOIX_JOB_NUM.
# Calling "matlab -r matfile(i, job_config)" for i in 1:job_num runs the desired job.
job_config="'"$1"'"
export EBOIX_MAT_CALL="/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r "
matfile='hbm_stats_exec_job'
eval $EBOIX_MAT_CALL '"'$matfile'(-1, '$job_config'), exit"'
num_jobs=$(cat NUM_JOBS)

# Run the jobs.
sbatch ./parallel.sh $matfile $num_jobs $job_config
