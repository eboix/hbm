#!/bin/bash
echo $1
com="\"try, hbm_stats_parfor("$1"), catch fopen('errors/error"$1"','wt+'), end, exit\""
echo $com
cd ~/sum17
com2="/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r "$com
eval $com2
