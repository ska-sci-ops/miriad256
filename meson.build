# MIRIAD: meson build script 
# Project ID and versioning
project('miriad', 'c', 'fortran', version: '2023.03.16')
project_name = 'miriad'
version    = '2023.03.16'
so_version = '0'

# Compile-time configuration
conf_data = configuration_data({
    'MAXANT': '512',          # Maximum number of antennas in array
    'MAXCHAN': '70000',       # Maximum number of channels
    'MAXAVER': '100000000',   # Maximum UV averaging
    'MAXWIN': '48',           # Maximum number of windows in uv data
    'MAXWIDE': '18'           # Maximum number of wideband channels
})

# Basic setup
builddir = meson.project_build_root()
cc = meson.get_compiler('c')
fs = import('fs')

# Fortran compile flags
comp_flags = ['-g', '-O', '-std=legacy', 
              '-Wno-maybe-uninitialized','-Wno-conversion', '-Wno-array-bounds', '-Wno-surprising', '-Wno-tabs']
add_project_arguments(comp_flags, language : ['fortran'])

# C compile flag (may be needed for MacOS/clang?)
#add_project_arguments(['-std=c99'], language : ['c'])

# Dependencies
cfitsio_dep  = cc.find_library('cfitsio', required : true)
wcslib_dep   = cc.find_library('wcs', required : true)
readline_dep = cc.find_library('readline', required : true)
pgplot_dep   = cc.find_library('pgplot', required : true)

# Generate rpfits dependency from subdirectory
rpfits_proj = subproject('rpfits')
rpfits_dep = rpfits_proj.get_variable('rpfits_dep')

# Generate tools required for pre-compilation
ratty_exe  = executable('ratty', 'tools/ratty.c')     # Preprocess .for files
intf2c_exe = executable('intf2c', 'tools/intf2c.c')   # Preprocess .f2c files
detab_exe  = executable('detab', 'tools/detab.c')     # Replaces tabs with spaces

# Subdirectories and includes
subdir('src')
subdir('inc')         # Provides 'inc'
subdir('inc/prog')    # Provides 'inc_prog'

# Generate LINPACK library from linpack fortran source codes
linpack_lib = library('linpack', srclist_linpack, install: true)

# Generate MIRIAD library 
miriad_lib =  library('mir', srclist_subs,
              include_directories: inc,
              link_with: linpack_lib,
              dependencies: [wcslib_dep, cfitsio_dep, readline_dep, rpfits_dep, pgplot_dep],
              install: true)

# Generate the MIRIAD command-line applications
foreach target : srclist_prog
    basename = target.full_path().split('/')[-1]
    if basename.endswith('.f')
        prog_name = basename.split('.')[0]
        message('Adding program: ' + prog_name)
        executable(prog_name, target,
                    include_directories: [inc, inc_prog],
                    link_with: [miriad_lib, linpack_lib],
                    dependencies: [wcslib_dep, cfitsio_dep, readline_dep, rpfits_dep, pgplot_dep],
                    install: true
                    )
    endif
endforeach