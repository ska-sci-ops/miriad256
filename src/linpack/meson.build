srclist = fs.read('../linpack.filelist').strip().split('\n')

srclist_linpack = []
message('Preprocessing src/linpack')
foreach filename : srclist
    progname = filename.split('.')[0]
    if filename.endswith('.for')
        #message('Preprocessing ' + filename)
        tgt = custom_target(progname, 
                    input : filename, 
                    output : filename.replace('.for', '.f'),
                    command : [ratty_exe, '-s', 'linux', '-I', '../inc', '-I', '@OUTDIR@', '@INPUT@', '@OUTPUT@']
                    )
    srclist_linpack += tgt
    endif
endforeach


