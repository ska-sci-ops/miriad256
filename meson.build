# MIRIAD: meson build script 
# Project ID and versioning
project('miriad', 'c', 'fortran', version: '2024.01.18')
project_name = 'miriad'
version    = '2024.01.18'
so_version = '0'

# Compile-time configuration
conf_data = configuration_data({
    'MAXANT': 256,          # Maximum number of antennas in array
    'MAXCHAN': 4096,        # Maximum number of channels
    'MAXAVER': 20000000,    # Maximum UV averaging
    'MAXWIN': 48,           # Maximum number of windows in uv data
    'MAXWIDE': 18           # Maximum number of wideband channels
})

# Add --prefix to conf_data object
conf_data.set('PREFIX', get_option('prefix'))

# Basic setup
builddir = meson.project_build_root()
cc = meson.get_compiler('c')
fs = import('fs')

# Fortran compile flags
comp_flags = ['-g', '-O0', '-std=legacy', 
              '-Wno-maybe-uninitialized','-Wno-conversion', '-Wno-array-bounds', '-Wno-surprising', '-Wno-tabs']
add_project_arguments(comp_flags, language : ['fortran'])

# C compile flag (may be needed for MacOS/clang?)
#add_project_arguments(['-std=c99'], language : ['c'])

# Generate rpfits dependency from subdirectory
rpfits_proj = subproject('rpfits')
rpfits_dep = rpfits_proj.get_variable('rpfits_dep')

# Dependencies
miriad_deps =  [
    cc.find_library('cfitsio', required : true), 
    cc.find_library('wcs', required : true), 
    cc.find_library('readline', required : true), 
    cc.find_library('pgplot', required : true),
    rpfits_dep
]

# Ratty preprocessor setup
ratty_include_flags = ['-I', 'inc', '-I', 'inc/subs', '-I', 'inc/prog', '-I', 'inc/wcslib', '-I', '@OUTDIR']

# Subdirectories and includes
subdir('inc')         # Provides 'inc'
subdir('inc/prog')    # Provides 'inc_prog'
subdir('inc/subs')    # Provides 'inc_subs'
subdir('inc/wcslib')  # Provides 'inc_wcs' (only needed by ratty preprocessor)
subdir('tools')       # Includes pre-processing tools ratty + intf2c
subdir('src')

# Generate LINPACK library from linpack fortran source codes
linpack_lib = library('linpack', srclist_linpack, install: true)

# Generate MIRIAD library 
miriad_lib =  library('mir', srclist_subs,
              include_directories: [inc, inc_subs],
              link_with: linpack_lib,
              dependencies: miriad_deps,
              install: true)

# Generate the MIRIAD command-line applications
foreach target : srclist_prog
    basename = target.full_path().split('/')[-1]
    if basename.endswith('.f')
        prog_name = basename.split('.')[0]
        message('Adding program: ' + prog_name)
        executable(prog_name, target,
                    include_directories: [inc, inc_prog, inc_subs],
                    link_with: [miriad_lib, linpack_lib],
                    dependencies: miriad_deps,
                    install: true
                    )
    endif
endforeach

# Copy over docs
install_subdir('doc', install_dir: get_option('prefix'))
install_subdir('cat', install_dir: get_option('prefix'))
install_subdir('scripts', install_dir: get_option('prefix'))