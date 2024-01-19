# Configure header files with compile-time variables
srclist = fs.read('inc.hdrlist').strip().split('\n')

# Run configure on any .in files, otherwise copy over header
# These are needed by the ratty preprocessor
foreach src : srclist
    if src.endswith('.in')
        message('Configuring ' + src)
        configure_file(input : src, output : src.replace('.in', ''),  configuration : conf_data)
    elif src.endswith('.h') or src.endswith('.inc')
        configure_file(input : src,  output : src,  configuration : conf_data)
    endif
endforeach

inc = include_directories('.')