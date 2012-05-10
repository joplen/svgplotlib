# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import svgplotlib.FLTK as Fl

Fl.alert('Dialog tests!')
print Fl.choice('Select button', 'Yes', 'No')
print Fl.input('Enter text', 'text line')
Fl.message('Welcome again!')
