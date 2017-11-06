#!/bin/bash 
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --time=2 --qos=1hr  

# sends mail when process begins, and 
# when it ends. Make sure you define your email 
#SBATCH --mail-type=begin 
#SBATCH --mail-type=end 
#SBATCH --mail-user=eboix@princeton.edu

MATLAB_RUN="/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -r "
MATLAB_CMD="parfor_test"

OVERALL_CMD=$MATLAB_RUN$MATLAB_CMD
echo $OVERALL_CMD
# eval $MATLAB_RUN $MATLAB_CMD

srun $OVERALL_CMD
