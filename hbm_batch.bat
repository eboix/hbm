#!/bin/bash
#SBATCH -N 1  # node count
#SBATCH -n 1  # number of tasks per node?
#SBATCH -t 0:30:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-user=eboix@princeton.edu
cd ~/sum17
/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r hbm_stats_parfor