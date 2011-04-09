#!/usr/bin/python
# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright © 2011 by Runar Tenfjord, Tenko.
import sys
from functools import partial

from xml.etree import ElementTree as etree
from xml.etree import cElementTree

from svgplotlib.TEX.Parser import Parser
from svgplotlib.TEX.Backends import SVGBackend
from svgplotlib.TEX.Font import BakomaFonts
from svgplotlib.SVG.Viewer import show

# TEX parser and fonts
tex_parser = Parser()
tex_fonts = BakomaFonts()

# Mangle names
MangleDict = lambda d: dict((name.replace('_','-'),value) for name,value in d.items())

def CloneElement(elem):
    '''
    Clone root element and ensure attribs are valid text items
    '''
    attrib = {}
    for name,value in elem.attrib.items():
        if isinstance(value, (tuple,list)):
            attrib[name] = unicode(value)[1:-1]
        elif name == 'root':
            continue
        else:
            attrib[name] = unicode(value)
    
    ret = etree.Element(elem.tag, attrib)
    ret.text = elem.text
    ret.tail = elem.tail
    
    for child in elem:
        ret.append(CloneElement(child))
        
    return ret

if sys.version[0] == '2' and int(sys.version[2]) < 7:
    class SVGBase:
        '''
        Wrapper class for etree.Element
        as in Python 2.6 and earlier etree.Element
        is a factor function and not a class.
        '''
        def __init__(self, name, **kwargs):
            self.element = element = etree.Element(name, **kwargs)

            self.__len__        = element.__len__
            self.__delitem__    = element.__delitem__
            self.__getitem__    = element.__getitem__
            self.__setitem__    = element.__setitem__

            self.clear          = element.clear
            self.get            = element.get
            self.items          = element.items
            self.keys           = element.keys
            self.set            = element.set
            self.append         = element.append
            self.find           = element.find
            self.findall        = element.findall
            self.findtext       = element.findtext
            self.insert         = element.insert
            self.makeelement    = element.makeelement
            self.remove         = element.remove

        @property
        def tag(self):
           return self.element.tag

        @property
        def text(self):
           return self.element.text

        @property
        def tail(self):
           return self.element.tail

        @property
        def attrib(self):
           return self.element.attrib

else:
   SVGBase = etree.Element
   
class SVGElement(SVGBase):
    '''
    Base class for SVG elements
    '''
    def __init__(self, name, **kwargs):
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        SVGBase.__init__(self, name, **attrib)
        parent.append(self)

class Defs(SVGBase):
    def __init__(self, **kwargs):
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        SVGBase.__init__(self, 'defs', **attrib)
        parent.append(self)
        
        root = attrib.get('root')
        self.Group = partial(Group, parent=self, root = root)
        self.Line = partial(SVGElement, 'line', parent=self, root = root)
        self.Polyline = partial(SVGElement, 'polyline', parent=self, root = root)
        self.Polygon = partial(SVGElement, 'polygon', parent=self, root = root)
        self.Rect = partial(SVGElement, 'rect', parent=self, root = root)
        self.Circle = partial(SVGElement, 'circle', parent=self, root = root)
        self.Ellipse = partial(SVGElement, 'ellipse', parent=self, root = root)
        self.Path = partial(SVGElement, 'path', parent=self, root = root)
        self.Text = partial(SVGElement, 'text', parent=self, root = root)
        
        self.linearGradient = partial(linearGradient, parent=self, root = root)
        self.radialGradient = partial(radialGradient, parent=self, root = root)
    
class TEX(SVGBase):
    def __init__(self, text, **kwargs):
        root = kwargs.pop('root')
        
        self.Use = partial(SVGElement, 'use', parent=self, root = root)
        self.Rect = partial(SVGElement, 'rect', parent=self, root = root)
        
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        
        x = attrib.pop('x', 0.)
        y = attrib.pop('y', 0.)
        rotation = attrib.pop('rotation', 0.)
        scale = attrib.pop('scale', 1.)
        
        transform = ["translate(%g,%g)" % (x,y)]
        if rotation != 0.:
            transform.append("rotate(%1.1g)" % rotation)
        if scale != 1.:
            transform.append("scale(%g)" % scale)
        
        SVGBase.__init__(self, 'g', transform = " ".join(transform), **attrib)
        parent.append(self)
        
        renderer = SVGBackend(self, root)
        box = tex_parser.parse(text, tex_fonts, 24, 72)
        renderer.render(box)
        
class EText(SVGBase):
    '''
    Text with glyps embedded in root object
    'defs' section.
    '''
    def __init__(self, font, text, **kwargs):
        root = kwargs.pop('root')
        
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        
        x = attrib.pop('x', 0.)
        y = attrib.pop('y', 0.)
        rotation = attrib.pop('rotation', 0.)
        scale = attrib.pop('scale', 1.)
        
        transform = ["translate(%g,%g)" % (x,y)]
        if rotation != 0.:
            transform.append("rotate(%1.1g)" % rotation)
        if scale != 1.:
            transform.append("scale(%g)" % scale)
        
        SVGBase.__init__(self, 'g', transform = " ".join(transform), **attrib)
        parent.append(self)
        
        # create glyps
        xpositions, glyph_ids, glyps = font.SVGGlyphs(text, root.glyphs)
        for x, glyph_id in zip(xpositions, glyph_ids):
            obj = SVGElement('use', x = "%g" % x, parent = self)
            obj.set('xlink:href', '#%s' % glyph_id)
            self.append(obj)
        
        # add to new glyps defs section
        defs = root.defs
        for name, path in glyps.iteritems():
            defs.Path(id = name, d = path)

class Gradient(SVGBase):
    def __init__(self, **kwargs):
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        SVGBase.__init__(self, self.__class__.__name__, **attrib)
        parent.append(self)
        
        root = attrib.get('root')
        self.Stop = partial(SVGElement, 'stop', parent=self, root = root)
        

class linearGradient(Gradient):
    pass

class radialGradient(Gradient):
    pass
        
class Group(SVGBase):
    def __init__(self, **kwargs):
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        SVGBase.__init__(self, 'g', **attrib)
        parent.append(self)
        
        root = attrib.get('root')
        self.Group = partial(Group, parent=self, root = root)
        self.Use = partial(SVGElement, 'use', parent=self, root = root)
        self.Line = partial(SVGElement, 'line', parent=self, root = root)
        self.Polyline = partial(SVGElement, 'polyline', parent=self, root = root)
        self.Polygon = partial(SVGElement, 'polygon', parent=self, root = root)
        self.Rect = partial(SVGElement, 'rect', parent=self, root = root)
        self.Circle = partial(SVGElement, 'circle', parent=self, root = root)
        self.Ellipse = partial(SVGElement, 'ellipse', parent=self, root = root)
        self.Path = partial(SVGElement, 'path', parent=self, root = root)
        self.Text = partial(SVGElement, 'text', parent=self, root = root)
        self.EText = partial(EText, parent=self, root = root)
        self.TEX = partial(TEX, parent=self, root = root)
        
class SVG(SVGBase):
    '''
    SVG root element
    
    Due to the SVG use of dashes in attribute names the char '_' is
    mangled to '-' automatic.
    
    SVG element constructors:
    - Defs
    - Use
    - Group
    - Line
    - Polyline
    - Polygon
    - Rect
    - Circle
    - Ellipse
    - Path
    - Text
    - EText (Embedded text)
    - TEX (math formula)
    
    All constructors create a new element with the root object as parent.
    To change the parent of the object pass the 'parent' attribute to the
    constructor.
    
    All constructors except for EText and TEX are standard SVG elements.
    
    Example::
        svg = SVG(width=50, height=50)
        g = svg.Group(stroke = "black")
        svg.Line(x1 = 0, y1 = 0., x2 = 50., y2 = 50., stroke='red', parent = g)
        g.Line(x1 = 0, y1 = 50., x2 = 50., y2 = 0.)
        svg.write('test.svg')
    '''
    HEADER = \
"""<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">"""
  
    def __init__(self, **kwargs):
        attr = {
            'version' : '1.1',
            'xmlns' : 'http://www.w3.org/2000/svg',
            'xmlns:svg' : 'http://www.w3.org/2000/svg',
            'xmlns:xlink' : 'http://www.w3.org/1999/xlink'
        }
        
        # mangle names
        attrib = MangleDict(kwargs)
        attr.update(attrib)
        
        SVGBase.__init__(self, 'svg', **attr)
        
        self.Defs = partial(Defs, parent=self, root = self)
        self.Use = partial(SVGElement, 'use', parent=self, root = self)
        self.Group = partial(Group, parent=self, root = self)
        self.Line = partial(SVGElement, 'line', parent=self, root = self)
        self.Polyline = partial(SVGElement, 'polyline', parent=self, root = self)
        self.Polygon = partial(SVGElement, 'polygon', parent=self, root = self)
        self.Rect = partial(SVGElement, 'rect', parent=self, root = self)
        self.Circle = partial(SVGElement, 'circle', parent=self, root = self)
        self.Ellipse = partial(SVGElement, 'ellipse', parent=self, root = self)
        self.Path = partial(SVGElement, 'path', parent=self, root = self)
        self.Text = partial(SVGElement, 'text', parent=self, root = self)
        self.EText = partial(EText, parent=self, root = self)
        self.TEX = partial(TEX, parent=self, root = self)
        
        # embedded font
        self.glyphs = set()
        self.defs = self.Defs()
        
    def write(self, file = sys.stdout, header = True, encoding='utf-8', **kwargs):
        '''
        Writes the element tree to a file, as XML. Attributes
        are converted to valid strings.
        
        file - A file name, or a file object opened for writing.
        header - Write svg decleration header to file
        encoding - Output encoding, default is 'utf-8'
        '''
        if header:
            if encoding is None:
                file.write(SVG.HEADER)
            else:
                file.write(SVG.HEADER.encode(encoding))
            
        tree = etree.ElementTree(CloneElement(self))
        tree.write(file, encoding = encoding, **kwargs)
    
    @property
    def width(self):
        return int(self.get('width', 500))
    
    @property
    def height(self):
        return int(self.get('height', 500))

if __name__ == '__main__':
    import math
    
    svg = SVG(width="150", height="150")
    '''
    g = svg.Group(stroke = "black", transform="translate(75,75)")
    delta = 30
    for angle in range(0,360 + delta,delta):
        x = 70.*math.sin(math.radians(angle))
        y = 70.*math.cos(math.radians(angle))
        g.Line(x1 = 0, y1 = 0, x2 = x, y2 = y)
    '''
    
    #svg.TEX('$\sum_{i=0}^\infty x_i$')
    
    grad = svg.defs.linearGradient(id="MyGradient")
    grad.Stop(offset="5%", stop_color="#F60")
    grad.Stop(offset="95%", stop_color="#FF6")
    
    svg.Rect(fill="url(#MyGradient)", stroke="black", stroke_width=5,
             x=0, y=0, width=150, height=150)
    svg.write()
    
    show(svg)
    