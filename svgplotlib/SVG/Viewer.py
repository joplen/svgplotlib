#!/usr/bin/python
# -*- coding: utf-8 -*-
from gzip import GzipFile
try:
    from xml.etree import cElementTree as etree
except ImportError:
    from xml.etree import ElementTree as etree

from svgplotlib.SVG import Backend

try:
    Viewer = Backend.Viewer
    show   = Backend.show
except AttributeError:
    print "Rendering functionality disabled"
    Viewer = lambda x : None
    show   = lambda x : None


def readFile(filename):
    """
    Open svg file and return xml object
    """
    GZIPMAGIC = '\037\213'
    
    if isinstance(filename, basestring):
        try:
            fh = open(filename, 'rb')
        except IOError:
            raise ValueError("could not open file '%s' for reading" % filename)
    else:
        fh = filename
        filename = 'unamed.svg'
    
    # test for gzip compression
    magic = fh.read(2)
    fh.seek(0)
    
    if magic == GZIPMAGIC:
        return etree.parse(GzipFile(filename, mode = 'r', fileobj = fh))
    else:
        return etree.parse(fh)
        
if __name__ == "__main__":
    from svgplotlib.SVG import SVG
    svg = SVG(width='150',height='150')
    grad = svg.defs.linearGradient(id='MyGradient')
    grad.Stop(offset='5%', stop_color='#F60')
    grad.Stop(offset='95%',stop_color='#FF6')
    svg.Rect(fill='url(#MyGradient)',stroke='black', strok_width='5',
            x=0,y=0,width=150,height=150 )
    svg.TEX('$\sum{i=0}^\infty x_i$')
    Viewer(svg)
