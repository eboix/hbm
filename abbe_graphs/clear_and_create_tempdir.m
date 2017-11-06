function clear_and_create_tempdir(tempdir)
    if( exist(tempdir, 'dir') )
         A = dir('tmpfiles')
        for k = 1:length(A)
            delete(fullfile(tempdir,A(k).name))
        end
        rmdir(tempdir)
    end
    if ~mkdir('.', tempdir)
        error(['Cannot make temporary directory at ' tempdir ' for auxiliary files.'])
    end
end