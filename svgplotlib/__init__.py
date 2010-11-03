#!python -u
# -*- coding: utf-8 -*-
import sys
import os
from os.path import join, abspath, dirname, expandvars
from collections import namedtuple

from svgplotlib.Config import config
import svgplotlib.Config as Config
from svgplotlib.freetype import FT2Font
from svgplotlib.SVG import SVG, tex_parser, tex_fonts
from svgplotlib.Scale import Scale

Size = namedtuple('Size', 'width height descent')

class Base(SVG):
    """
    Base class for all plots
    """
    PAD = 10
    TICK = 20
    
    # default color scheme (plotkit)
    COLORS = (
        "#476fb2",
        "#be2c2b",
        "#85b730",
        "#734a99",
        "#26a1c5",
        "#fb8707",
    )
                    
    def __init__(self, *args, **kwargs):
        SVG.__init__(self)
        
        self.xscale, self.yscale = 1.,1.
        
        self.xmajorTicks, self.xminorTicks = None,None
        self.ymajorTicks, self.yminorTicks = None,None
        
        # font
        self.fontFamily = kwargs.get('fontFamily', Config.DEFAULTFONT)
        self.fontStyle = kwargs.get('fontStyle', Config.DEFAULTFONTSTYLE)
        self.fontSize = kwargs.get('fontSize', Config.DEFAULTFONTSIZE)
        
        font = self.font = getFont(family = self.fontFamily, style = self.fontStyle)
        font.set_size(self.fontSize)
    
    def textSize(self, text):
        if not text:
            return Size(0., 0., 0.)
            
        self.font.set_text(text)
        width, height = self.font.get_width_height()
        
        descent = self.font.get_descent()
        
        return Size(width/64., height/64., descent/64.)
    
    def TEXSize(self,  text, fontSize = 24, dpi = 72):
        if not text:
            return Size(0., 0., 0.)
        
        box = tex_parser.parse(text, tex_fonts, fontSize, dpi)
        
        return Size(box.width, box.height, box.depth - 5)
            
    def buildTicks(self, minx, maxx, maxNumSteps = 5, maxMinSteps = 2):
        scale = Scale()
        stepSize = scale.autoScale(minx, maxx, maxNumSteps)
        x1, x2 =  scale.buildTicks(minx, maxx, stepSize, maxMinSteps = maxMinSteps)
        return x1, x2
        
    def grid(self):
        xscale = self.xscale
        yscale = self.yscale
        width = self.plotWidth
        height = self.plotHeight
        
        path_data = []
        add = path_data.append
        
        if not self.ymajorTicks is None:
            for y in self.ymajorTicks[1:-1]:
                ypos = height - y*yscale
                add('M %g,%g' % (0 + self.TICK, ypos))
                add('L %g,%g' % (width - self.TICK, ypos))
        
        if not self.xmajorTicks is None:
            for x in self.xmajorTicks[1:-1]:
                xpos = x*self.xscale
                add('M %g,%g' % (xpos, 0 + self.TICK))
                add('L %g,%g' % (xpos, height - self.TICK))
        
        if path_data:
            self.plotArea.Path(d = ' '.join(path_data), stroke_dasharray="2 5")
        
    def xaxis(self, pos, flip = False, text = True, fmt = None):
        xscale = self.xscale
        
        if fmt is None:
            fmt = lambda x: u"%g" % x
            
        sc = -1 if flip else 1
        path_data = []
        add = path_data.append
        
        for x in self.xmajorTicks[1:-1]:
            x = x - self.minx
            xpos = x*self.xscale
            add('M %g,%g' % (xpos, pos))
            add('L %g,%g' % (xpos, pos - sc*self.TICK))
            
        if text:
            for x in self.xmajorTicks:
                s = unicode(fmt(x))
                size = self.textSize(s)
                
                x = x - self.minx
                
                if flip:
                    ypos = pos - .5*self.fontSize
                else:
                    ypos = pos + size.height + .5*self.fontSize
                    
                xpos = x*self.xscale - .5*size.width
                
                self.plotArea.EText(self.font, s, x = xpos, y = ypos, **self.textStyle)
            
        for x in self.xminorTicks:
            x = x - self.minx
            
            add('M %g,%g' % (x*xscale, pos))
            add('L %g,%g' % (x*xscale, pos - .5*sc*self.TICK))
        
        self.plotArea.Path(d = ' '.join(path_data))
    
    def yaxis(self, pos, flip = False, text = True, fmt = None):
        yscale = self.yscale
        height = self.plotHeight
        sc = -1 if flip else 1
        
        if fmt is None:
            fmt = lambda y: u"%g" % y
            
        path_data = []
        add = path_data.append
        
        for y in self.ymajorTicks[1:-1]:
            y = y - self.miny
            ypos = height - y*yscale
            add('M %g,%g' % (pos, ypos))
            add('L %g,%g' % (pos + sc*self.TICK, ypos))
            
        if text:
            for y in self.ymajorTicks:
                s = unicode(fmt(y))
                size = self.textSize(s)
                
                y = y - self.miny
                
                if flip:
                    xpos = pos + self.PAD
                else:
                    xpos = pos - self.PAD - size.width
                
                ypos = height - y*yscale + .5*size.height
                
                self.plotArea.EText(self.font, s, x = xpos, y = ypos, **self.textStyle)
        
        for y in self.yminorTicks:
            y = y - self.miny
            ypos = height - y*yscale
            add('M %g,%g' % (pos, ypos))
            add('L %g,%g' % (pos + .5*sc*self.TICK, ypos))
            
        self.plotArea.Path(d = ' '.join(path_data))

class Font(FT2Font):
    def __init__(self, fname):
        FT2Font.__init__(self, fname)
    
    def SVGGlyphs(self, text, glyps_seen = None):
        '''
        Return SVG paths of glyps
        '''
        if glyps_seen is None:
            glyps_seen = set()
            
        family = self.family_name.replace(' ','')
        style = self.style_name.replace(' ','')
        
        glyph_map = {}
        cmap = self.get_charmap()
        lastgind = None
        
        currx = 0
        xpositions = []
        glyph_ids = []
        
        for c in text:
            ccode = ord(c)
            gind = cmap.get(ccode)
            
            if gind is None:
                ccode = ord('?')
                gind = 0
                
            if lastgind is None:
                kern = 0
            else:
                kern = self.get_kerning(lastgind, gind)
            
            glyph = self.load_char(ccode)
            
            char_id = "%s-%s-%d" % (family, style, ccode)
            if not char_id in glyps_seen:
                path_data = []
                append = path_data.append
                
                for step in glyph.path:
                    code = step[0]

                    if code == 0:   # MOVE_TO
                        x, y = step[1:]
                        append('M %g %g' % (x, -y))
                        
                    elif code == 1: # LINE_TO
                        x, y = step[1:]
                        append('L %g %g' % (x, -y))
                        
                    elif code == 2: # CURVE3
                        x1, y1, x2, y2 = step[1:]
                        append('Q %g %g %g %g' % (x1, -y1, x2, -y2))
                        
                    elif code == 3: # CURVE4
                        x1, y1, x2, y2, x3, y3 = step[1:]
                        append('C %g %g %g %g %g %g' % (x1, -y1, x2, -y2, x3, -y3))
                        
                    elif code == 4: # ENDPOLY
                        append('Z')
                
                glyps_seen.add(char_id)
                glyph_map[char_id] = " ".join(path_data)
            
            currx += (kern / 64.0)

            xpositions.append(currx)
            glyph_ids.append(char_id)

            currx += glyph.linearHoriAdvance / 65536.
            lastgind = gind
        
        return xpositions, glyph_ids, glyph_map
    
_fonts = {}

def getFont(family = Config.DEFAULTFONT, style = Config.DEFAULTFONTSTYLE):
    try:
        variants = _fonts[family]
    except KeyError:
        variants = _fonts[Config.DEFAULTFONT]
    
    try:
        path = variants[style]
    except KeyError:
        path = variants[Config.DEFAULTFONTSTYLE]
    
    return Font(path)

# load fonts into dict
for fontpath in config.get('fonts', 'fontpaths').split(';'):
    if not os.path.exists(fontpath):
                continue
    
    for filename in os.listdir(fontpath):
        name, ext = os.path.splitext(filename)
        if ext.lower() not in frozenset(('.ttf', '.otf')):
            continue
        
        path = os.path.join(fontpath, filename)
        font = FT2Font(path)
        
        _fonts.setdefault(font.family_name, {})[font.style_name] = path

if __name__ == '__main__':
    font = getFont()
    print font