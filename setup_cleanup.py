#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright 2007 by Runar Tenfjord, Tenko.
import sys
import os
import shutil

if os.path.exists('build'):
    print("remove 'build' directory")
    shutil.rmtree('build') 
    
for filename in ('FLTK/FLTK.cpp', 
                 'FLTK.pyd',
                 'FLTK.so',
                 'svgplotlib/@src/freetype.c',
                 'svgplotlib/@src/VG/VG.c',
                 'svgplotlib/@src/cairosvg.c' ):
    if os.path.exists(filename):
        print("remove '%s' file" % filename)
        os.remove(filename) 

print('')

#input('Press enter to continue')
