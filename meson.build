project('miriad', 'c', 'fortran', version: '2023.03.16')

project_name = 'miriad'
version    = '2023.03.16'
so_version = '0'

builddir = meson.project_build_root()
cc = meson.get_compiler('c')


# Fortran compile flags
comp_flags = ['-g', '-O', '-std=legacy', 
              '-Wno-maybe-uninitialized','-Wno-conversion', '-Wno-array-bounds', '-Wno-surprising', '-Wno-tabs']

add_project_arguments(comp_flags, language : ['fortran'])

# C compile
add_project_arguments(['-std=c99', '-Wno-deprecated-non-prototype'], language : ['c'])

# Generate filelists
fs = import('fs')
src_lists = {
    'subs':    fs.read('src/subs.filelist').strip().split('\n'),
    'linpack': fs.read('src/linpack.filelist').strip().split('\n'),
    'prog':    fs.read('src/prog.filelist').strip().split('\n'),
}

src_abspath_lists = {
    'subs': [],
    'linpack': [],
    'prog': []
}

# Get rpfits
rpfits_proj = subproject('rpfits')
rpfits_dep = rpfits_proj.get_variable('rpfits_dep')

# Dependencies
cfitsio_dep  = cc.find_library('cfitsio', required : true)
wcslib_dep   = cc.find_library('wcs', required : true)
readline_dep = cc.find_library('readline', required : true)
pgplot_dep   = cc.find_library('pgplot', required : true)

# Generate addhis.for
ratty_exe = executable('ratty', 'tools/ratty.c')
detab_exe = executable('detab', 'tools/detab.c')
intf2c_exe = executable('intf2c', 'tools/intf2c.c')

subdir('src')
inc = include_directories('inc')
inc_subs = include_directories('inc/subs')
inc_prog = include_directories('inc/prog')

linpack_lib = library('linpack', srclist_linpack, install: true)

miriad_lib =  library('mir', srclist_subs,
              include_directories: inc,
              link_with: linpack_lib,
              dependencies: [wcslib_dep, cfitsio_dep, readline_dep, rpfits_dep, pgplot_dep],
              install: true)

foreach target : srclist_prog
    basename = target.full_path().split('/')[-1]
    if basename.endswith('.f')
        prog_name = basename.split('.')[0]
        message('Building ' + prog_name)
        executable(prog_name, target,
                    include_directories: [inc, inc_subs, inc_prog],
                    link_with: [miriad_lib, linpack_lib],
                    dependencies: [wcslib_dep, cfitsio_dep, readline_dep, rpfits_dep, pgplot_dep],
                    install: true
                    )
    endif
endforeach