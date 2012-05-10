#!/usr/bin/python
# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright © 2011 by Runar Tenfjord, Tenko.

try:
    import PyQt4
except ImportError:
    print 'failed to import PyQt.'
    print 'falling back to FLTK'
    try:
        import svgplotlib.FLTK as Fl
    except ImportError:
        print 'Failed to import FLTK'
        pass
    else:
        import fltk
        Viewer = fltk.Viewer
        show   = fltk.show
else:
    import Qt
    Viewer = Qt.Viewer
    show   = Qt.show

try:
    import VG
except ImportError:
    pass
