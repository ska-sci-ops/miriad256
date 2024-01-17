srclist = fs.read('../subs.filelist').strip().split('\n')

srclist_subs = []
message('Preprocessing src/subs')
foreach filename : srclist
    progname = filename.split('.')[0]
    if filename.endswith('.for')
        tgt = custom_target(filename, 
                    input : filename, 
                    output : filename.replace('.for', '.f'),
                    command : [ratty_exe, '-s', 'linux', '-I', '../inc', '-I', '@OUTDIR@', '@INPUT@', '@OUTPUT@']
                    )
        srclist_subs += tgt
    elif filename.endswith('.f2c')
        tgt = custom_target(filename, 
                    input :  filename, 
                    output : filename.replace('.f2c', '.c'),
                    command : [intf2c_exe, '-s', 'linux', '@INPUT@', '@OUTPUT@']
                    )
        srclist_subs += tgt
    else
        tgt = custom_target(filename, 
                    input :  filename, 
                    output : filename,
                    command : ['cp', '@INPUT@', '@OUTPUT@']
                    )
        srclist_subs += tgt
    endif
endforeach
