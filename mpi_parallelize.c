#include <stdio.h>
#include "mpi.h"

int main( argc, argv )
int argc;
char **argv;
{
    int tot_job_number = atoi(argv[2]);
    int rank, size;
    MPI_Comm new_comm;

    MPI_Init( &argc, &argv );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_split( MPI_COMM_WORLD, rank == 0, 0, &new_comm );
    if (rank == 0)
        master_io( MPI_COMM_WORLD, new_comm, tot_job_number );
    else
        slave_io( MPI_COMM_WORLD, new_comm );

    MPI_Finalize( );
    return 0;
}

/* This is the master */
int master_io( MPI_Comm master_comm, MPI_Comm comm, int tot_job_number)
{
  //  fprintf( stderr, "INIT MASTER\n");
    int        i,proc_num,job_num, size; 
    int CANCEL_JOB = -1;
    char       buf[256];
    MPI_Status status;
    
    MPI_Comm_size( master_comm, &size );
    for(job_num = 1; job_num <= tot_job_number; job_num++) {
 //       fprintf(stderr, "LISTENING IN ON MESSAGES\n");
        MPI_Recv(&proc_num, 1, MPI_INT, MPI_ANY_SOURCE, 0, master_comm, &status );
 //       fprintf(stderr, "MESSAGE %d RECEIVED\n", proc_num);
        MPI_Send(&job_num,1,MPI_INT,proc_num,0,master_comm);
    }
    for(proc_num = 1; proc_num < size; proc_num++) {
 //       fprintf(stderr, "Cancelling process %d", proc_num);
        MPI_Send(&CANCEL_JOB,1,MPI_INT,proc_num,0,master_comm);
    }
    return 0;
}

/* This is the slave */
int slave_io( MPI_Comm master_comm, MPI_Comm comm, char** argv)
{
    
  //  fprintf( stderr, "INIT SLAVE\n");
    char buf[256];
    int  rank;
    
    // Announce yourself as slave.
    MPI_Comm_rank( master_comm, &rank );
    MPI_Send(&rank, 1, MPI_INT, 0, 0, master_comm);
    
 //   fprintf(stderr, "SLAVE %d MSG SENT\n", rank);

    while(1) {
   //     fprintf(stderr, "%d Looking for JOB", rank);
        int job_num;
        MPI_Status status;
        
        // Receive a job and do it.
        MPI_Recv(&job_num,1,MPI_INT,0,0,master_comm,&status);
       // fprintf(stderr, "SLAVE %d MSG RECEIVED. JOB: %d\n", rank, job_num);
        if(job_num == -1) {
            break;
        }
        else {
            char buf[2048];
            printf("Processor: %d Job: %d\n", rank, job_num);
            sprintf(buf, "eval $EBOIX_MAT_CALL \"try, %s(%d), catch fopen('errors/error%d','wt+'), end, exit\"",argv[1],job_num)
            system(buf);
        }
        
        // Announce that you're ready again!
        MPI_Send(&rank,1,MPI_INT,0,0,master_comm);
    }
        
    return 0;
}
