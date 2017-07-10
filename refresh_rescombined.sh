#!/bin/bash 
#SBATCH -N 1 # node count 
#SBATCH --ntasks-per-node=1
#SBATCH -t 0:30:00 

# Run the jobs.
/usr/licensed/bin/matlab -nojvm -nosplash -nodisplay -singleCompThread -r "rescombined_refresh, exit"

git add rescombined
