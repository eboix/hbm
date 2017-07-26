#!/bin/bash
MATLAB_RUN="/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r "
MATLAB_CMD="\"combine_hbm_stats('"$1"'); exit\""
echo $MATLAB_RUN $MATLAB_CMD
eval $MATLAB_RUN $MATLAB_CMD
