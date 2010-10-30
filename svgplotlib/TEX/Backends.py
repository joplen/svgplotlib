#!python -u
# -*- coding: utf-8 -*-
# Copyright 2007 by Runar Tenfjord, Tenko.
import re
import math

from svgplotlib.TEX.Parser import ship
from svgplotlib.TEX.Font import unichr_safe, ft

def isTEX(s):
    """Check if string is a TEX string"""
    if re.match(r'.*\$.+\$.*', s, re.MULTILINE | re.DOTALL):
        return True
        
    return False
    
class ImageBackend:
    '''
    Image backend renders to a 8 bit grey scale image
    '''
    def __init__(self):
        self.calcsize = True
        self.xvalues = []
        self.yvalues = []
        
        self.glyps = []
        self.rects = []
    
    def render_glyph(self, ox, oy, info):
        """
        Draw a glyph described by *info* to the reference point
        (*ox*,*oy*).
        """
        if self.calcsize:
            self.xvalues.append(ox + info.metrics.xmin)
            self.xvalues.append(ox + info.metrics.xmax)
            self.yvalues.append(oy - info.metrics.ymax)
            self.yvalues.append(oy - info.metrics.ymin)
        else:
            self.glyps.append((ox, oy, info))
            
    def render_rect_filled(self, x1, y1, x2, y2):
        """
        Draw a filled black rectangle from (*x1*, *y1*) to (*x2*, *y2*).
        """
        if self.calcsize:
            self.xvalues.append(x1)
            self.xvalues.append(x2)
            self.yvalues.append(y1)
            self.yvalues.append(y2)
        else:
            self.rects.append((x1, y1, x2, y2))
        
    def render(self, box):
        # first pass to calculate size
        ship(self, 0, 0, box)
        
        minx = min(self.xvalues) - 1
        maxx = max(self.xvalues) + 1
        miny = min(self.yvalues) - 1
        maxy = max(self.yvalues) + 1
        
        width = maxx - minx
        height = maxy - miny - box.depth
        depth =  maxy - miny - box.height
        
        image = ft.FT2Image(math.ceil(width), math.ceil(height + depth))
        
        # second pass
        self.calcsize = False
        ship(self, -minx, -miny, box)
        
        for ox, oy, info in self.glyps:
            thetext = unichr_safe(info.num)
            ccode = ord(thetext)
            
            info.font.set_size(info.fontsize, 72)
            glyph = info.font.load_char(ccode)
            
            info.font.draw_glyph_to_bitmap(image, ox, oy - info.metrics.iceberg, glyph)
        
        for x1, y1, x2, y2 in self.rects:
            image.draw_rect_filled(x1, y1, x2, y2)
        
        return image

class PDFBackend:
    '''
    PDF backend renders to a reportlab canvas
    '''
    def __init__(self, canvas, fontcallback = None):
        self.canvas = canvas
        self.fontcallback = fontcallback
    
    def set_canvas_size(self, width, height, depth):
        'Dimension the drawing canvas'
        self.width = math.ceil(width)
        self.height = math.ceil(height)
        self.depth = math.ceil(depth)
    
    def render_glyph(self, ox, oy, info):
        """
        Draw a glyph described by *info* to the reference point
        (*ox*,*oy*).
        """
        font = info.font.fname
        
        if not self.fontcallback is None:
            self.fontcallback(font)
        
        oy = self.height - oy + info.offset
        
        self.canvas.setFont(font, info.fontsize)
        self.canvas.drawString(ox, oy, unichr_safe(info.num))
    
    def render_rect_filled(self, x1, y1, x2, y2):
        """
        Draw a filled black rectangle from (*x1*, *y1*) to (*x2*, *y2*).
        """
        width = x2 - x1
        height = y2 - y1
        
        ox = x1
        oy = self.height - y2 + 2*height
        
        self.canvas.rect(ox, oy, width, height, fill=1)
    
    def render(self, box):
        self.set_canvas_size(box.width, box.height, box.depth)
        
        self.canvas.setLineWidth(0)
        self.canvas.setDash([])
        ship(self, 0, -self.depth, box)
        
        return self.width, self.height + self.depth, self.depth
        
        
class SVGBackend:
    def __init__(self, svg, root = None):
        self.svg = svg
        
        if root is None:
            self.root = svg
        else:
            self.root = root
            
        self.seen = set()
    
    def set_canvas_size(self, width, height, depth):
        'Dimension the drawing canvas'
        self.width = math.ceil(width)
        self.height = math.ceil(height)
        self.depth = math.ceil(depth)
        
    def render_glyph(self, ox, oy, info):
        """
        Draw a glyph described by *info* to the reference point
        (*ox*,*oy*).
        """
        thetext = unichr_safe(info.num)
        defid = info.font.SVGDefID(thetext, info.fontsize)
        
        args =(ox, self.depth + oy - info.offset - self.height)
        transform = "translate(%g,%g)" % args
        obj = self.svg.Use(transform = transform)
        obj.set('xlink:href', '#%s' % defid)
        
        if not defid in self.seen:
            self.seen.add(defid)
        
            path = info.font.SVGGlyph(ord(thetext), info.fontsize)
            self.root.glyph_defs.Path(id = defid, d = path)
        
    def render_rect_filled(self, x1, y1, x2, y2):
        """
        Draw a filled black rectangle from (*x1*, *y1*) to (*x2*, *y2*).
        """
        width = x2 - x1
        height = y2 - y1
        
        x = x1
        y = self.depth + y1 - height - self.height
        
        self.svg.Rect(x = x, y = y,
                      width = width, height = height,
                      fill="black", stroke='none')
            
    def render(self, box):
        self.set_canvas_size(box.width, box.height, box.depth)
        ship(self, 0, -self.depth, box)
        return self.width, self.height + self.depth, self.depth
        
if __name__ == '__main__':
    from svgplotlib.TEX.Parser import Parser
    from svgplotlib.TEX.Font import BakomaFonts
    
    '''
    from reportlab.platypus import *
    from reportlab.pdfbase.ttfonts import TTFont
    from reportlab.pdfbase import pdfmetrics
    
    class Math(Flowable):
        def __init__(self, s, l=None):
            Flowable.__init__(self)
            
            self.hAlign='CENTER'
            self.s = s
            self.l = l
            self.parser = Parser()
            self.fonts = BakomaFonts()
            self.box = self.parser.parse(self.s, self.fonts, 12, 72)
            
        def wrap(self, aW, aH):
            return self.box.width, self.box.height
        
        def drawOn(self, canv, x, y, _sW=0):
            if _sW and hasattr(self,'hAlign'):
                from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT, TA_JUSTIFY
                a = self.hAlign
                if a in ('CENTER','CENTRE', TA_CENTER):
                    x = x + 0.5*_sW
                elif a in ('RIGHT',TA_RIGHT):
                    x = x + _sW
                elif a not in ('LEFT',TA_LEFT):
                    raise ValueError, "Bad hAlign value "+str(a)
            
            seen = set()
            def registerFont(fontname):
                if not fontname in seen:
                    seen.add(fontname)
                    pdfmetrics.registerFont(TTFont(fontname, fontname))
                
            canv.saveState()
            canv.translate(x, y)
            try:    
                renderer = PDFBackend(canv, registerFont)
                renderer.render(self.box)
                    
            finally:
                canv.restoreState()
        
        
    doc = SimpleDocTemplate("mathtest.pdf")
    Story = [Math(r'$\mathcal{R}\prod_{i=\alpha\mathcal{B}}'\
                  r'^\infty a_i\sin(2 \pi f x_i)$')]
    doc.build(Story)
    '''
    
    '''
    from svgplotlib.SVG import SVG, show
    
    svg = SVG(stroke = 'none', fill = 'black')
    
    parser = Parser()
    renderer = SVGBackend(svg)
    fonts = BakomaFonts()
    
    #text = r'$\alpha > \beta$'
    #text = r'$\alpha_i > \beta_i$'
    text = r'$\sum_{i=0}^\infty x_i$'
    #text = r'$\frac{3}{4} \binom{3}{4} \stackrel{3}{4}$'
    #text = r'$\frac{5 - \frac{1}{x}}{4}$'
    #text = r'$\sqrt{2}$'
    #text = r'$\sqrt[3]{x}$'
    
    box = parser.parse(text, fonts, 12, 72)
    width, height, descent = renderer.render(box)
    #svg.write()
    scale = 4.
    svg.set('width', scale*width)
    svg.set('height', scale*height)
    svg.set('transform', 'translate(0,%g) scale(%g)' % (height*scale - descent*scale,scale))
    show(svg, svg.width, svg.height)
    '''
    
    import Image, ImageOps
    
    parser = Parser()
    renderer = ImageBackend()
    fonts = BakomaFonts()
    
    #text = r'$\alpha > \beta$'
    #text = r'$\alpha_i > \beta_i$'
    text = r'$\sum_{i=0}^\infty x_i$'
    
    box = parser.parse(text, fonts, 64, 72)
    buffer = renderer.render(box)
    
    img = Image.fromstring('L', (buffer.width, buffer.height), buffer.tobytes())
    img = ImageOps.invert(img)
    img.save('test.png')