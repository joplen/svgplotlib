#!python -u
# -*- coding: utf-8 -*-
import sys
import os
from os.path import join, abspath, dirname, expandvars
from ConfigParser import SafeConfigParser

# default font path
defaults = {}
if hasattr(sys, 'frozen'):
    BASE = abspath(dirname(sys.executable))
else:
    BASE = abspath(dirname(__file__))

defaults['defaultfonts'] = join(BASE, 'fonts')

# system font path
if sys.platform == "win32":
    sysfonts = expandvars('%SystemRoot%/fonts')
else:
    sysfonts = '/usr/share/fonts/'

defaults['sysfonts'] = sysfonts

if sys.platform == "win32":
    defaults['CommonProgramFiles'] =  expandvars('%CommonProgramFiles%')
    
# read config file
cfgfiles = []
cfgname = 'svgplotlib.cfg'
if sys.platform == "win32":
    cfgfiles.append(join(expandvars('~'), cfgname))
else:
    cfgfiles.append(join(expandvars('~'), '.svgplotlib'))
    
cfgfiles.append(join(BASE, cfgname))

config = SafeConfigParser(defaults)
for filename in cfgfiles:
    if not os.path.exists(filename):
        continue
    config.read(filename)

# get defaults
if config.has_option('fonts', 'family'):
    DEFAULTFONT = config.get('fonts', 'family')
else:
    DEFAULTFONT = 'Bitstream Vera Sans'

if config.has_option('fonts', 'family'):
    DEFAULTTEXFONTS = config.get('fonts', 'texfontpaths')
else:
    DEFAULTTEXFONTS = join(BASE, 'fonts')
    
if config.has_option('fonts', 'style'):
    DEFAULTFONTSTYLE = config.get('fonts', 'style')
else:
    DEFAULTFONTSTYLE = 'Roman'

if config.has_option('fonts', 'size'):
    DEFAULTFONTSIZE = config.getint('fonts', 'size')
else:
    DEFAULTFONTSIZE = 'Roman'
    