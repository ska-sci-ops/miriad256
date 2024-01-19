# Configure header files with compile-time variables
srclist = fs.read('../wcslib.hdrlist').strip().split('\n')

# Run configure on any .in files, otherwise copy over header
# These are needed by the ratty preprocessor
foreach src : srclist
    configure_file(input : src,  output : src,  configuration : conf_data)
endforeach

inc_wcs = include_directories('.')