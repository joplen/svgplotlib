#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

if os.name == "posix":
    GL = "GL"
    GLU = "GLU"
    VG_extra_link_args = [ ]
    XLIBS = ["png", "jpeg", "z", "GL", "pthread"] 
    XLINKARGS = [] 
    if sys.platform == 'darwin':
        devdir = '/Developer/SDKs/MacOSX10.{0}.sdk/usr/X11/include'
        if os.path.exists(devdir.format(7)):
            devdir = devdir.format(7)
            freetype_includes = [devdir, '{0}/freetype2'.format(devdir)]
            cairo_includes    = [devdir, '{0}/cairo'.format(devdir)]
            extra_vg_includes = [devdir]
        elif os.path.exists(devdir.format(6)):
            devdir = devdir.format(6)
            freetype_includes = [devdir, '{0}/freetype2'.format(devdir)]
            cairo_includes    = [devdir, '{0}/cairo'.format(devdir)]
            extra_vg_includes = [devdir]

        VG_extra_link_args = ["-L/usr/X11/lib"]
        if sys.maxsize > 2**32:
            VG_extra_link_args += ['-arch','x86_64']
    else:
        freetype_includes = ['/usr/include/freetype2']
        cairo_includes    = ['/usr/include/cairo']
        extra_vg_includes = []
    
elif os.name == "nt":
    GL = "OPENGL32"
    GLU = "GLU32"
    XLIBS = ["fltk_jpeg", "fltk_png", "fltk_z", "OPENGL32", "pthread", "ole32", "uuid", "comctl32"] 
    XLINKARGS = ["-mwindows", "-mno-cygwin"] 
    VG_extra_link_args = ["-mwindows","-mno-cygwin"]
    freetype_include_dir = []
    cairo_includes = []
    extra_vg_includes = []

extensions = [
    Extension("svgplotlib.freetype",
                  sources=["svgplotlib/@src/freetype.pyx"],
                  depends=["svgplotlib/@src/freetypeLib.pxd"],
                  include_dirs = ['svgplotlib'] + freetype_includes,
                  library_dirs = ['svgplotlib'],
                  libraries=['freetype']),
]

if '--without-cairo' in sys.argv:
    idx = sys.argv.index('--without-cairo')
    del sys.argv[idx]
else:
    extensions.append(
        Extension("svgplotlib.cairosvg",
                  sources=["svgplotlib/@src/cairosvg.pyx"],
                  include_dirs = ['svgplotlib'] + cairo_includes,
                  libraries = ['svg-cairo','svg','cairo']),
    )

if '--with-shiva' in sys.argv:
    idx = sys.argv.index( '--with-shiva')
    del(sys.argv[idx])
    extensions.append(
        Extension("svgplotlib.VG",
              sources = [ "svgplotlib/@src/shivavg/src/" + fname 
                    for fname in [
                        'shExtensions.c',
                        'shArrays.c',
                        'shVectors.c',
                        'shPath.c',
                        'shImage.c',
                        'shPaint.c',
                        'shGeometry.c',
                        'shPipeline.c',
                        'shParams.c',
                        'shContext.c',
                        'shOffscreen.c',
                        'shVgu.c',
                        ] ] 
                    + 
                    [ 'svgplotlib/@src/VG/VG.pyx' ] ,
              depends = ['svgplotlib/@src/VG/VGLib.pxd'],
              include_dirs  = [
                  'svgplotlib/@src/VG',
                  'svgplotlib/@src/shivavg/include/vg',
                  'svgplotlib/@src/shivavg/include',
                  'svgplotlib/@src/shivavg/src',
                  '/usr/include',
                  '/usr/include/x86_64-linux-gnu',
              ] + extra_vg_includes,
              libraries     = [GL, GLU, 'm'],
              extra_link_args =  VG_extra_link_args,
          ) )

if '--with-fltk' in sys.argv:
    idx = sys.argv.index('--with-fltk')
    del(sys.argv[idx])
    extensions.append(
       Extension("FLTK",
                   sources=["FLTK/FLTK.pyx"],
                   depends = ["FLTK/FLTKLib.pxd"],
                   include_dirs = ['FLTK'],
                   library_dirs = ['FLTK'],
                   libraries=["fltk", "fltk_images", "fltk_gl"] + XLIBS, 
                   extra_link_args = XLINKARGS,
                   language="c++"),
       )




classifiers = '''\
Environment :: Console
Development Status :: 4 - Beta
Intended Audience :: Developers
License :: OSI Approved :: License :: OSI Approved :: BSD License
Operating System :: OS Independent
Programming Language :: Python
Topic :: Multimedia :: Graphics
'''

setup(
    name = 'svgplotlib',
    version = '0.3',
    description = 'SVG plotting library',
    long_description = '''\
**svgplotlib** is a lightweight python package for creating SVG
graphs and charts.

The TEX package and freetype extension have been ported from matplotlib.
Compared to matplotlib the dependency om numpy have been removed.

**Highlights**

 * Pie chart
 * Bar chart
 * Gantt chart
 * XY plot
 * date plot
 * Support a subset of TEX syntax similar to matplotlib.
 * Inlines font glyps in SVG file for consistent results.
 * General SVG support.
''',
    classifiers = [value for value in classifiers.split("\n") if value],
        
    author='Runar Tenfjord',
    author_email = 'runar.tenfjord@tenko.no',
    license = 'BSD',
    download_url='http://pypi.python.org/pypi/svgplotlib/',
    url = 'http://code.google.com/p/svgplotlib/',
    
    platforms = ['any'],
    requires = ['pyparsing'],

    ext_modules=extensions,
        
    cmdclass = {'build_ext': build_ext},
    packages=['svgplotlib', 'svgplotlib.TEX', 'svgplotlib.SVG','svgplotlib.SVG.Backend'],
    package_data={'svgplotlib': ['svgplotlib.cfg', 'fonts/*.*']},
)
