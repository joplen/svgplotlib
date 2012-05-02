#!python -u
# -*- coding: utf-8 -*-
import sys
import math
import itertools

from svgplotlib import Base

class Pie(Base):
    """
    Simple Pie style plot
    
    Example::
        >>> graph =Pie(
        ...    (10,50,100),
        ...    title = 'Simple pie plot',
        ...    labels = ('Cars', 'Boats', 'Planes'),
        ... )
        >>> 
    """
    def __init__(self, values, labels = None, colors = None, **kwargs):
        # smaller default font
        if not 'fontSize' in kwargs:
            kwargs['fontSize'] = 24
            
        super(Pie,self).__init__(**kwargs)
        
        titleScale = kwargs.get('titleScale', 1.25)
        titleColor = kwargs.get('titleColor', 'black')
        labelColor = kwargs.get('labelColor', 'black')
        
        if labels is None:
            labels = [str(i) for i in range(len(values))]
            
        if colors is None:
           colors = self.COLORS
        
        style = self.style = {
            'stroke'        : 'black',
            'stroke-width'  : '1',
            'fill'          : 'black',
        }
        
        textStyle = self.textStyle = {
            'stroke'        : 'none',
        }
        
        # main group
        g = self.Group(**style)
        
        # plot area size
        SIZE = max(500, kwargs.get('size', 500))
        
        self.plotWidth = SIZE
        self.plotHeight = SIZE
        
        dy = self.PAD
        dx = self.PAD
        
        title = unicode(kwargs.get('title', ''))
        titleSize = None
        if title:
            titleSize = self.textSize(title)
            dy += titleScale*(titleSize.height + titleSize.descent) + self.PAD
            
        WIDTH = 2*dx + SIZE
        HEIGHT = dy + SIZE + self.PAD
        
        # set total size 
        self.set('width', WIDTH)
        self.set('height',  HEIGHT)
        
        if title:
            xpos = .5*WIDTH - .5*titleScale*titleSize.width
            ypos = .5*dy + .5*titleScale*titleSize.height - titleScale*titleSize.descent
            
            g.EText(self.font, title, x = xpos, y = ypos, scale = titleScale,
                    fill = titleColor, **textStyle)
        
        
        # create plot area
        plotArea = g.Group(transform="translate(%g,%g)" % (dx, dy), **style)
        self.plotArea = plotArea
        
        def path_data(cx = 0, cy = 0, r = 1, start = 0., end = 90.):
            path = []
            add = path.append
            
            dx = r*math.cos(math.radians(start))
            dy = r*math.sin(math.radians(start))
            
            add('M%g,%g' % (cx,cy))
            add('l%g,%g' % (dx, dy))
            
            dx = r*math.cos(math.radians(end))
            dy = r*math.sin(math.radians(end))
            
            larc = int((end - start) > 180.)
            add('A%g,%g 0 %d,1 %g,%g' % (r,r,larc, cx + dx, cy + dy))
            add('z')
            
            return " ".join(path)
        
        color = itertools.cycle(colors)
        total = float(sum(values))
        angle = 0.
        scale = 4.
        for value, label in zip(reversed(values), reversed(labels)):
            delta = 360.*(value/total)
            r = .5*SIZE
            plotArea.Path(d = path_data(.5*SIZE, .5*SIZE, r, angle, angle + delta),
                          fill = color.next(), stroke = 'white',
                          stroke_width = 2, stroke_linejoin='round')
            
            # find center point for text
            cangle = math.radians(angle + .5*delta)
            dx = .5*r*math.cos(cangle)
            dy = .5*r*math.sin(cangle)
            
            size = self.textSize(unicode(label))
            
            xpos = .5*SIZE + dx - .5*size.width
            ypos = .5*SIZE + dy + .5*size.height - .5*size.descent
            plotArea.EText(self.font, label, x = xpos, y = ypos, fill = labelColor,
                            **textStyle)
            
            angle += delta
                          
if __name__ == '__main__':
    from svgplotlib.SVG import show
    
    graph =Pie(
        (10,50,100),
        title = 'Simple pie plot',
        labels = ('Cars', 'Boats', 'Planes'),
    )
    
    show(graph, graph.width, graph.height)
    
