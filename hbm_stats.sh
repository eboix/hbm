#!/bin/bash

# Load openmpi environment 
module load openmpi 
module load intel

# Compile the C file
make

# The MATLAB file we will be calling to do the jobs is given below.
# Convention: calling "matlab -r matfile(-1)" exports the total number of jobs to EBOIX_JOB_NUM.
# Calling "matlab -r matfile(i)" for i in 1:job_num runs the desired job.
export EBOIX_MAT_CALL="/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r "
matfile='hbm_stats_exec_job'
eval $EBOIX_MAT_CALL '"'$matfile', exit"'
num_jobs=$(cat NUM_JOBS)

# Run the jobs.
./parallel.sh $matfile $num_jobs
