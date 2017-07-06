#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
cd ~/sum17
/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r hbm_stats_parfor