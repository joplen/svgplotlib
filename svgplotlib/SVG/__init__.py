#!/usr/bin/python
# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright © 2011 by Runar Tenfjord, Tenko.
import sys
from functools import partial

try:
    from xml.etree import cElementTree as etree
except ImportError:
    from xml.etree import  ElementTree as etree

try:
    from cairosvg import CairoSVG
except ImportError:
    CairoSVG = None

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO
    
from svgplotlib.TEX.Parser import Parser
from svgplotlib.TEX.Backends import SVGBackend
from svgplotlib.TEX.Font import BakomaFonts

# TEX parser and fonts
tex_parser = Parser()
tex_fonts = BakomaFonts()

# Mangle names
MangleDict = lambda d: dict((name.replace('_','-'),value) for name,value in d.items())

def sanitize(item):
    name,value=item
    if isinstance(value, (tuple,list)):
        value = unicode(value)[1:-1]
    elif name == 'root':
        return (None,None)
    else:
        #attrib[name] = unicode(value)
        value = unicode(value)
    return (name,value,)

def CloneElement(elem):
    '''
    Clone root element and ensure attribs are valid text items
    '''
    attrib = dict(map( sanitize, elem.attrib.iteritems() ))
    attrib.pop(None,None)
    
    ret = etree.Element(elem.tag, attrib)
    ret.text = elem.text
    ret.tail = elem.tail
    
    for child in elem.getchildren():
        ret.append(CloneElement(child))
    return ret

class SVGBase(object):
    '''
    Wrapper class for etree.Element
    as in Python 2.6 and earlier etree.Element
    is a factor function and not a class.
    '''
    def __init__(self, name, **kwargs):
        self.element = element = etree.Element(name, **kwargs)

        for i in dir(element):
            setattr(self, i, getattr(element,i) )

    def __iter__(self):
        return self.iter()

    @property
    def tag(self):
       return self.element.tag
    @tag.setter
    def tag(self,value):
        self.element.tag = value
    @tag.deleter
    def tag(self):
        del(self.element.tag)

    @property
    def text(self):
       return self.element.text
    @text.setter
    def text(self,value):
        self.element.text = value
    @text.deleter
    def text(self):
        del(self.element.text)

    @property
    def tail(self):
       return self.element.tail
    @tail.setter
    def tail(self,value):
        self.element.tail = value
    @tail.deleter
    def tail(self):
        del(self.element.tail)

    @property
    def attrib(self):
       return self.element.attrib
   
class SVGElement(SVGBase):
    '''
    Base class for SVG elements
    '''
    def __init__(self, name, **kwargs):
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        super(SVGElement,self).__init__(name, **attrib)
        parent.append(self.element)

class CSSElement(SVGBase):
    def __init__(self, **kwargs):
        """kwargs should be a dictionary of dictionaries.
        Top level keys are CSS selectors, and inner dicts
        hold the style key : value pairs.
        
        >>> from svgplotlib.SVG import SVG
        >>> cssdict =  { '#boxId' : { 'border_color' : 'blue',
        ...                           'border'       : '1px solid' } }
        >>> svg = SVG()
        >>> svg.Style( **cssdict )
        """
        from svgplotlib.SVG.CSS import CSS
        #attrib  = MangleDict(kwargs)
        parent = kwargs.pop( 'parent' )
        mroargs = { 'root' :   kwargs.pop('root') }
        super(CSSElement,self).__init__('style', type='text/css', **mroargs)
        self.styles = CSS(**kwargs)
        self.text = self.styles.__repr__()
        parent.append(self.element)
    def append(self, *args, **kwargs):
        self.styles.update( *args, **kwargs )
        self.text = self.styles.__repr__()
    @property
    def text(self):
        return '<![CDATA[\n{0}\n]]>'.format(self.styles)
    @text.setter
    def text(self,value):
        self.element.text = value
    @text.deleter
    def text(self):
        del(self.element.text)

class JSElement(SVGBase):
    def __init__(self, **kwargs):
        attrib = MangleDict(kwargs)
        parent = attrib.pop('parent')
        if 'type' not in attrib:
            attrib.update( { 'type' : 'text/ecmascript' } )
        super(JSElement,self).__init__('script', **attrib)
        self._script = ''
        parent.append(self.element)
    def append(self, *args, **kwargs):
        self.styles.update( *args, **kwargs )
    @property
    def tag(self):
        return 'script'
    @property
    def text(self):
        return u'<![CDATA[\n{0}\n]]>'.format(self._script)
    @text.setter
    def text(self, value):
        self._script = value
        self.element.text = u'<![CDATA[\n{0}\n]]>'.format(value)

class Defs(SVGBase):
    def __init__(self, **kwargs):
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        super(Defs,self).__init__('defs', **attrib)
        parent.append(self.element)
        
        root            = attrib.get('root')
        self.Group      = partial(Group,                  parent=self, root = root)
        self.Line       = partial(SVGElement, 'line',     parent=self, root = root)
        self.Polyline   = partial(SVGElement, 'polyline', parent=self, root = root)
        self.Polygon    = partial(SVGElement, 'polygon',  parent=self, root = root)
        self.Rect       = partial(SVGElement, 'rect',     parent=self, root = root)
        self.Circle     = partial(SVGElement, 'circle',   parent=self, root = root)
        self.Ellipse    = partial(SVGElement, 'ellipse',  parent=self, root = root)
        self.Path       = partial(SVGElement, 'path',     parent=self, root = root)
        self.Text       = partial(SVGElement, 'text',     parent=self, root = root)
        self.Tspan      = partial(SVGElement, 'tspan',    parent=self, root = root)
        
        self.linearGradient = partial(linearGradient, parent=self, root = root)
        self.radialGradient = partial(radialGradient, parent=self, root = root)
    
class TEX(SVGBase):
    def __init__(self, text, **kwargs):
        root = kwargs.pop('root')
        
        self.Use  = partial(SVGElement, 'use' , parent=self, root = root)
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
        
        super(TEX, self).__init__('g',transform=' '.join(transform), **attrib)
        parent.append(self.element)
        
        renderer = SVGBackend(self, root)
        box = tex_parser.parse(text, tex_fonts, 24, 72)
        renderer.render(box)
        
class EText(SVGBase):
    '''
    Text with glyphs embedded in root object
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
        
        super(EText, self).__init__('g', transform=' '.join(transform), **attrib)
        parent.append(self.element)
        
        # create glyps
        xpositions, glyph_ids, glyps = font.SVGGlyphs(text, root.glyphs)
        for x, glyph_id in zip(xpositions, glyph_ids):
            obj = SVGElement('use', x = "%g" % x, parent = self)
            obj.set('xlink:href', '#%s' % glyph_id)
            self.append(obj.element)
        
        # add to new glyps defs section
        defs = root.defs
        for name, path in glyps.iteritems():
            defs.Path(id = name, d = path)

class Gradient(SVGBase):
    def __init__(self, **kwargs):
        """
        Creates a gradient definition. Give each gradient
        an id and reference the gradient as a fill for 
        any objects that should be using it. The gradient
        should thus be defined in the SVG's def section.
        e.g.
        >>> from svgplotlib.SVG.Viewer import Viewer
        >>> svg = SVG(width="150", height="150")
        >>> grad = svg.defs.linearGradient(id="MyGradient")
        >>> s = grad.Stop(offset="5%", stop_color="#F60")
        >>> s = grad.Stop(offset="95%", stop_color="#FF6")
        >>> r = svg.Rect(fill="url(#MyGradient)", stroke="black", stroke_width=5,
        ...      x=0, y=0, width=150, height=150)
        >>> v = Viewer(svg)
        """
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        super(Gradient,self).__init__( self.__class__.__name__, **attrib )
        parent.append(self.element)
        
        root = attrib.get('root')
        self.Stop = partial(SVGElement, 'stop', parent=self, root = root)
        

class linearGradient(Gradient):
    pass

class radialGradient(Gradient):
    pass
        
class Group(SVGBase):
    def __init__(self, **kwargs):
        '''
        >>> import math
        >>> svg = SVG(width="150", height="150")
        >>> g = svg.Group(stroke = "black", transform="translate(75,75)")
        >>> delta = 30
        >>> for angle in range(0,360 + delta,delta):
        ...     x = 70.*math.sin(math.radians(angle))
        ...     y = 70.*math.cos(math.radians(angle))
        ...     l = g.Line(x1 = 0, y1 = 0, x2 = x, y2 = y)
        '''
        # mangle names
        attrib = MangleDict(kwargs)
        
        parent = attrib.pop('parent')
        super(Group, self).__init__('g', **attrib)
        parent.append(self.element)
        
        root = attrib.get('root')
        self.Group    = partial(Group,                  parent=self, root = root)
        self.Use      = partial(SVGElement, 'use',      parent=self, root = root)
        self.Line     = partial(SVGElement, 'line',     parent=self, root = root)
        self.Polyline = partial(SVGElement, 'polyline', parent=self, root = root)
        self.Polygon  = partial(SVGElement, 'polygon',  parent=self, root = root)
        self.Rect     = partial(SVGElement, 'rect',     parent=self, root = root)
        self.Circle   = partial(SVGElement, 'circle',   parent=self, root = root)
        self.Ellipse  = partial(SVGElement, 'ellipse',  parent=self, root = root)
        self.Path     = partial(SVGElement, 'path',     parent=self, root = root)
        self.Text     = partial(SVGElement, 'text',     parent=self, root = root)
        self.Tspan    = partial(SVGElement, 'tspan',    parent=self, root = root)
        self.EText    = partial(EText,                  parent=self, root = root)
        self.TEX      = partial(TEX,                    parent=self, root = root)

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
        >>> from svgplotlib.SVG.Viewer import show
        >>> svg = SVG(width=50, height=50)
        >>> g = svg.Group(stroke = "black")
        >>> l = svg.Line(x1 = 0, y1 = 0., x2 = 50., y2 = 50., stroke='red', parent = g)
        >>> l = g.Line(x1 = 0, y1 = 50., x2 = 50., y2 = 0.)
        >>> show(svg)
        >>> with file('test.svg','w') as out:
        ...     svg.write(out)
        >>> import os
        >>> os.remove('test.svg')
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
        
        super(SVG, self).__init__('svg', **attr)
        
        self.Defs       = partial(Defs,                     parent=self, root = self)
        self.Style      = partial(CSSElement,               parent=self, root = self)
        self.Script     = partial(JSElement ,               parent=self, root = self)
        self.Group      = partial(Group,                    parent=self, root = self)
        self.Circle     = partial(SVGElement, 'circle',     parent=self, root = self)
        self.Ellipse    = partial(SVGElement, 'ellipse',    parent=self, root = self)
        self.Line       = partial(SVGElement, 'line',       parent=self, root = self)
        self.Path       = partial(SVGElement, 'path',       parent=self, root = self)
        self.Polygon    = partial(SVGElement, 'polygon',    parent=self, root = self)
        self.Polyline   = partial(SVGElement, 'polyline',   parent=self, root = self)
        self.Rect       = partial(SVGElement, 'rect',       parent=self, root = self)
        self.Text       = partial(SVGElement, 'text',       parent=self, root = self)
        self.Use        = partial(SVGElement, 'use',        parent=self, root = self)
        self.EText      = partial(EText,                    parent=self, root = self)
        self.TEX        = partial(TEX,                      parent=self, root = self)
        
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
    
    def writePNG(self, filename, width = -1, height = -1, scale = 1.):
        '''
        render to png file
        '''
        if CairoSVG is None:
            raise ImportError('cairo extension not available')
        
        if isinstance(filename, basestring):
            fh = open(filename, 'wb')
        else:
            fh = filename
            
        svgfh = StringIO()
        self.write(svgfh)
        svgfh.seek(0)
        
        writer = CairoSVG(svgfh)
        writer.toPNG(fh, width, height, scale)
    
    def writePDF(self, filename, width = -1, height = -1, scale = 1.):
        '''
        render to pdf file
        '''
        if CairoSVG is None:
            raise ImportError('cairo extension not available')
        
        if isinstance(filename, basestring):
            fh = open(filename, 'wb')
        else:
            fh = filename
            
        svgfh = StringIO()
        self.write(svgfh)
        svgfh.seek(0)
        
        writer = CairoSVG(svgfh)
        writer.toPDF(fh, width, height, scale)
    
    def toArray(self, width = -1, height = -1, scale = 1.):
        '''
        render to image buffer in RGBA format
        '''
        if CairoSVG is None:
            raise ImportError('cairo extension not available')
            
        svgfh = StringIO()
        self.write(svgfh)
        svgfh.seek(0)
        
        writer = CairoSVG(svgfh)
        return writer.toRGBA(width, height, scale)
        
    @property
    def width(self):
        return int(self.get('width', 500))
    
    @property
    def height(self):
        return int(self.get('height', 500))

    
if __name__ == '__main__':
    from svgplotlib.SVG.Viewer import Show
    import math
    
    svg = SVG(width="150", height="150")
    
    grad = svg.defs.linearGradient(id="MyGradient")
    grad.Stop(offset="5%", stop_color="#F60")
    grad.Stop(offset="95%", stop_color="#FF6")
    
    svg.Rect(fill="url(#MyGradient)", stroke="black", stroke_width=5,
             x=0, y=0, width=150, height=150)
    svg.TEX('$\sum_{i=0}^\infty x_i$')
    #svg.write()
    show(svg)
