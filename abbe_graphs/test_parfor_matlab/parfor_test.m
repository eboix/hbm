clear A

poolobj = parpool;

fprintf('number of workers: %g\n', poolobj.NumWorkers);

parfor i = 1:8
   A(i) = i;
end
A
save('out_A.mat','A');
quit;

