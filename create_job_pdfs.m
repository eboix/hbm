files = dir('completed_jobs/*.m');
for file = files'
    
    [~,name_without_extension,~] = fileparts(file.name);
    job_pdf = ['job_pdfs/' name_without_extension '.pdf'];
    if ~exist(job_pdf,'file')
        hbm_stats_parser(['completed_jobs/' file.name]);
    end
end
