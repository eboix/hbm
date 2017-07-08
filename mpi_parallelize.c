#include <stdio.h>
#include "mpi.h"


int main( argc, argv )
int argc;
char **argv;
{
    int tot_job_number = atoi(argv[2]);
    fprintf(stderr, "INITING PROC\n");
    fprintf(stderr, "MATLAB FILE TO CALL: %s\n", argv[1]);
    fprintf(stderr, "TOT NUMBER OF JOBS: %d\n", tot_job_number);
    int rank, size;
    MPI_Comm new_comm;

    MPI_Init( &argc, &argv );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_split( MPI_COMM_WORLD, rank == 0, 0, &new_comm );
    if (rank == 0)
        master_io( MPI_COMM_WORLD, new_comm, tot_job_number );
    else
        slave_io( MPI_COMM_WORLD, new_comm, argv );

    MPI_Finalize( );
    return 0;
}

/* This is the master */
int master_io( MPI_Comm master_comm, MPI_Comm comm, int tot_job_number)
{
    int        i,proc_num,job_num, size; 
    int CANCEL_JOB = -1;
    char       buf[256];
    MPI_Status status;
    
    MPI_Comm_size( master_comm, &size );
    for(job_num = 1; job_num <= tot_job_number; job_num++) {
        MPI_Recv(&proc_num, 1, MPI_INT, MPI_ANY_SOURCE, 0, master_comm, &status );
        MPI_Send(&job_num,1,MPI_INT,proc_num,0,master_comm);
    }
    // All jobs have been sent out.
    for(proc_num = 1; proc_num < size; proc_num++) {
        MPI_Send(&CANCEL_JOB,1,MPI_INT,proc_num,0,master_comm);
    }
    // Serially confirm that each job has cancelled.
    for(proc_num = 1; proc_num < size; proc_num++) {
        MPI_Recv(&i, 1, MPI_INT, proc_num, 0, master_comm, &status );
        if(i != -1) {
            fprintf(stderr, "I should only be getting cancel messages!\n");
            return 1;
        }
    }
    // All jobs are done: now you can quickly post-process.
    if(argc > 3) {
        char matlab_command[2048];
        char* matlab_file = argv[3];
        sprintf(matlab_command, "%s", matlab_file);
        run_matlab(matlab_command, tot_job_number + 1);
    }
    
    return 0;
}

/* This is the slave */
int slave_io( MPI_Comm master_comm, MPI_Comm comm, char** argv)
{
    int  rank;
    int EXITING = -1;
    
    // Announce yourself as slave.
    MPI_Comm_rank( master_comm, &rank );
    MPI_Send(&rank, 1, MPI_INT, 0, 0, master_comm);
   
    while(1) {
        int job_num;
        MPI_Status status;
        
        // Receive a job and do it.
        MPI_Recv(&job_num,1,MPI_INT,0,0,master_comm,&status);
        if(job_num == -1) {
            break;
        }
        else {
            char matlab_command[2048];
    	    char* matlab_file = argv[1];
            sprintf(matlab_command, "%s(%d)", matlab_file, job_num);
            run_matlab(matlab_command, job_num);
        }
        
        // Announce that you're ready again!
        MPI_Send(&rank,1,MPI_INT,0,0,master_comm);
    }
    MPI_Send(&EXITING,1,MPI_INT,0,0,master_comm);
        
    return 0;
}

void run_matlab(char* matlab_command, int job_num) {
  char buf[2048];
  char* MATLAB_RUN = "/usr/licensed/bin/matlab -singleCompThread -nodisplay -nosplash -nojvm -r"; 
  sprintf(buf, "%s \"try, %s, catch fopen('errors/error%d','wt+'), end, exit\"",MATLAB_RUN,matlab_command,job_num);
  fprintf(stderr, "%s\n", buf);
  system(buf);
}
