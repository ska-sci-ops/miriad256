srclist = fs.read('../prog.hdrlist').strip().split('\n')

# Run configure on any .in files, otherwise copy over header files
foreach src : srclist
    if src.endswith('.in')
        message('Configuring ' + src)
        configure_file(input : src, output : src.replace('.in', ''),  configuration : conf_data)
    elif src.endswith('.h')
        configure_file(input : src,  output : src,  configuration : conf_data)
    endif
endforeach

inc_prog = include_directories('.')