# Configure header files with compile-time variables
srclist = fs.read('../prog.filelist').strip().split('\n')

srclist_prog = []
message('Preprocessing src/prog')
foreach filename : srclist
    progname = filename.split('.')[0]
    if filename.endswith('.for')
        tgt = custom_target(filename, 
                    input : filename, 
                    output : filename.replace('.for', '.f'),
                    command : [ratty_exe, '-s', 'linux'] + ratty_include_flags + ['@INPUT@', '@OUTPUT@'],
                    )
        srclist_prog += tgt
    elif filename.endswith('.f2c')
        tgt = custom_target(filename, 
                    input :  filename, 
                    output : filename.replace('.f2c', '.c'),
                    command : [intf2c_exe, '-s', 'linux', '@INPUT@', '@OUTPUT@'],
                    )
        srclist_prog += tgt
    else
        tgt = custom_target(filename, 
                    input :  filename, 
                    output : filename,
                    command : ['cp', '@INPUT@', '@OUTPUT@']
                    )
        srclist_prog += tgt
    endif
endforeach