# Generate tools required for pre-compilation
# Preprocess .for files with ratty
# Note: the includes are to ensure headers are compiled before ratty is run
ratty_exe   = executable('ratty',   'ratty.c')    
intf2c_exe  = executable('intf2c',  'intf2c.c')    # Preprocess .f2c files
detab_exe   = executable('detab',   'detab.c')     # Replaces tabs with spaces
doc2man_exe = executable('doc2man', 'doc2man.c')   # Converts docs to man files

miriad_exe  = executable('miriad', 'miriad.c', install: true) 