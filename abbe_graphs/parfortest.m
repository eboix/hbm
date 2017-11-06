c = parcluster;
j = createJob(c,'Name','Job_52a');
createTask(j,@rand,1,{2,4});

submit(j)