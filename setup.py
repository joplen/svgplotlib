#!/usr/bin/python
# -*- coding: utf-8 -*-
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

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
    version = '0.1',
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
    
    ext_modules=[
        Extension("svgplotlib.freetype",
                  sources=["svgplotlib/freetype.pyx"],
                  depends=["svgplotlib/freetypeLib.pxd"],
                  include_dirs = ['svgplotlib','svgplotlib/include'],
                  library_dirs = ['svgplotlib'],
                  libraries=['freetype']),
        ],
        
    cmdclass = {'build_ext': build_ext},
    packages=['svgplotlib', 'svgplotlib.TEX'],
    package_data={'svgplotlib': ['svgplotlib.cfg', 'fonts/*.*']},
)