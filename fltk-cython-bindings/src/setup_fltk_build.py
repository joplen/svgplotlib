#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright 2007 by Runar Tenfjord, Tenko.
import sys
import os
import glob
import shutil

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

if os.name == "posix":
    XLIBS = ["png", "jpeg", "z", "GL", "pthread"] 
    XLINKARGS = [] 

elif os.name == "nt":
    XLIBS = ["fltk_jpeg", "fltk_png", "fltk_z", "OPENGL32", "pthread", "ole32", "uuid", "comctl32"] 
    XLINKARGS = ["-mwindows", "-mno-cygwin"] 

sys.argv.append('build_ext')
        
try:
    setup(
      name = 'FLTK',
      ext_modules=[
        Extension("FLTK",
                    sources=["FLTK/FLTK.pyx"],
                    depends = ["FLTK/FLTKLib.pxd"],
                    include_dirs = ['FLTK'],
                    library_dirs = ['FLTK'],
                    libraries=["fltk", "fltk_images", "fltk_gl"] + XLIBS, 
                    extra_link_args = XLINKARGS,
                    language="c++"),
        ],
        
      cmdclass = {'build_ext': build_ext}
    )
except:
    print('Traceback\n:%s\n' % str(sys.exc_info()[-2]))
else:
    print('\n')

#input('Press enter to continue')
