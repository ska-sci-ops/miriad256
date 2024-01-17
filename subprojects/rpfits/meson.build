project('rpfits', 'c', 'fortran', version: '2.25')

project_name = 'rpfits'
version    = '2.25'
so_version = '0'
builddir = meson.project_build_root()

comp_flags = ['-g', '-O', '-Wall', '-fimplicit-none', '-fdefault-real-8', '-fdefault-double-8', 
              '-fdefault-integer-8', '-ffree-line-length-none', '-fbacktrace', '-std=legacy']
add_project_arguments(comp_flags, language : ['fortran'])

fs = import('fs') 
srcs_c      = fs.read('meson_srclist_c.txt').strip().split('\n')
srcs_f      = fs.read('meson_srclist_fortran.txt').strip().split('\n')

# Generate RPFITS library
rpfits_lib = library(project_name, [srcs_c, srcs_f],  
              version : version, soversion : so_version, 
              include_directories: ['code'],
              install: true)

# Generate rpfhdr utility
rpfhdr_exe = executable('rpfhdr', 'code/rpfhdr.c',
                include_directories: ['code'],
                link_with: rpfits_lib,
                install: true
                )

# Generate rpfex utility
rpfex_exe = executable('rpfex', 'code/rpfex.c',
                include_directories: ['code'],
                link_with: rpfits_lib,
                install: true
                )

rpfits_dep = declare_dependency(include_directories : [],
  link_with : rpfits_lib)