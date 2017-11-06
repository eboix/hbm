import os, random, time, subprocess, string, smtplib

def check_slurm_status():
    out = subprocess.check_output(['sacct --format="State"'], shell=True)
    out = out.split('\n');
    
    last = 'empty'
    for line in out:
        line = string.strip(line);
        if line:
            last = line;
    return last

def main():
    QUEUE_DIR = "queued_jobs"
    COMPLETED_DIR = "completed_jobs"

    num_iter = 0;

    while True:
        # Check for jobs in the queued_jobs directory.
        while os.listdir(QUEUE_DIR):
            curr_job_file = random.choice(os.listdir(QUEUE_DIR))
            
            # Send the job to slurm for parallelization.
            os.system("./hbm_stats.sh " + QUEUE_DIR + "/" + curr_job_file);


            # Check ~every minute if slurm is done.
            # If slurm is not done, keep on checking.
            last_status = 'RUNNING';
            while last_status == 'RUNNING' or last_status == 'PENDING':
                time.sleep(120);
                last_status = check_slurm_status();

            # Once slurm is done, it has either COMPLETED or there was something unexpected.
            if last_status != 'COMPLETED':
                 # If there was something unexpected, then send an e-mail to eboix@princeton.edu, and STOP everything.
                smtpObj = smtplib.SMTP('localhost');
                smtpObj.sendmail('eboix@princeton.edu', 'eboix@princeton.edu', 'SLURM JOB ' + curr_job_file + 'ON YOUR QUEUE ENDED WITH STATUS ' + done_status);
                exit(1)
            else:
                # Else gather up the res files into the rescombined files, move the current job into the completed_jobs directory,
                # and loop back to the beginning.
                os.system("./refresh_rescombined.sh");
                
                # Then parse the stats! This is pretty short... maybe I should do it on the computing nodes!

                os.system("mv " + QUEUE_DIR + "/" + curr_job_file + " " + COMPLETED_DIR + "/" + curr_job_file);
                os.system("git add completed_jobs");
                os.system("git commit -a -m 'Finished " + curr_job_file + " job.'");
                os.system("git push -u origin master");
        # Check every five minutes for updates to the queued_jobs directory.
        time.sleep(300);
        os.system("git pull --no-edit origin master");
        num_iter += 1;
        if num_iter % 300 == 0:
            smtpObj = smtplib.SMTP('localhost');
            smtpObj.sendmail('eboix@princeton.edu', 'eboix@princeton.edu', 'Your handy python script on adroit.princeton.edu is still running! It is currently ' + num_iter + 'iterations in.');
main();
