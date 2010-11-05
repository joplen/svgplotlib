#!python -u
# -*- coding: utf-8 -*-
import sys
import itertools

from svgplotlib import Base

class Bar(Base):
    """
    Simple vertical bar plot
    
    Example::
    
        graph = Bar(
            (10,50,100),
            width = 1000, height = 500,
            titleColor = 'blue',
            title = 'Simple bar plot',
            xlabel = 'X axis',
            ylabel = 'Y axis',
            grid = True,
        )
    """
    def __init__(self, values, labels = None, colors = None, **kwargs):
        Base.__init__(self, **kwargs)
        
        if labels is None:
            labels = [str(i) for i in range(len(values))]
            
        if colors is None:
           colors = self.COLORS
                    
        grid = kwargs.get('grid', False)
        
        titleColor = kwargs.get('titleColor', 'black')
        titleScale = kwargs.get('titleScale', 1.25)
        
        labelColor = kwargs.get('labelColor', 'black')
        xlabelColor = kwargs.get('xlabelColor', 'black')
        ylabelColor = kwargs.get('ylabelColor', 'black')
        
        
        style = self.style = {
            'stroke'        : 'black',
            'stroke-width'  : '1',
            'fill'          : 'black',
        }
        
        textStyle = self.textStyle = {
            'stroke'        : 'none',
        }
        
        # plot area width and height
        width = kwargs.get('width', 500)
        height = kwargs.get('height', 500)
        assert width > 0 and height > 0, 'width and height must be larger than 0'
        
        aspect = float(width)/height
        assert aspect > .2 and aspect < 5., 'aspect must be between .2 and 5'
        
        self.plotWidth = width
        self.plotHeight = height
        
        # build yticks
        miny = min(values)
        maxy = max(values)
        
        if miny == maxy:
            miny -= 1
            maxy += 1
            
        maxNumSteps = kwargs.get('maxNumSteps', 5)
        maxMinSteps = kwargs.get('maxMinSteps', 5)
        
        y1, y2 = self.buildTicks(miny, maxy, maxNumSteps = maxNumSteps, maxMinSteps = maxMinSteps)
        self.ymajorTicks, self.yminorTicks = y1, y2
        
        # calculate scale
        miny = self.miny = min(min(y1), min(y2 or (sys.maxint,)))
        maxy = self.maxy = max(max(y1), max(y2 or (-sys.maxint,)))
        
        self.yscale = self.plotHeight/(maxy - miny)
        
        # main group
        g = self.Group(**style)
        
        # label size
        delta = self.fontSize + 2*self.PAD
        
        # find height
        dy = .5*self.fontSize
        
        title = unicode(kwargs.get('title', ''))
        titleSize = None
        if title:
            titleSize = self.textSize(title)
            dy += titleScale*(titleSize.height + titleSize.descent) + self.PAD
        
        h = dy                  # Top line space
        h += self.plotHeight    # Plot area
        h += delta              # xaxis labels
        
        xlabel = unicode(kwargs.get('xlabel', ''))
        xlabelSize = None
        if xlabel:
            xlabelSize = self.textSize(xlabel)
            h += xlabelSize.height + xlabelSize.descent + self.PAD
        
        # find width
        w = 0
        dx = 0
        
        ylabel = unicode(kwargs.get('ylabel', ''))
        ylabelSize = None
        if ylabel:
            ylabelSize = self.textSize(ylabel)
            dx += ylabelSize.height + ylabelSize.descent + 2*self.PAD
        
        # yaxis labels
        maxSize = 0
        for y in self.ymajorTicks:
            s = u"%g" % y
            size = self.textSize(s)
            maxSize = max(maxSize, size.width)
        dx += maxSize + self.PAD
        
        w += dx                 # side space
        w += self.plotWidth     # Plot area
        w += delta + self.PAD
        
        # set total size 
        self.set('width', w)
        self.set('height', h)
        
        # plot title and labels
        if title:
            xpos = .5*w - .5*titleScale*titleSize.width
            ypos = .5*dy + .5*titleScale*titleSize.height - titleScale*titleSize.descent
            
            g.EText(self.font, title, x = xpos, y = ypos, scale = titleScale,
                    fill = titleColor, **textStyle)
        
        if xlabel:
            xpos = .5*w - .5*xlabelSize.width
            ypos = h - self.PAD
            
            g.EText(self.font, xlabel, x = xpos, y = ypos, fill = xlabelColor, **textStyle)
        
        if ylabel:
            xpos = ylabelSize.height + ylabelSize.descent + self.PAD
            ypos = dy + .5*self.plotHeight + .5*ylabelSize.width
            
            g.EText(self.font, ylabel, x = xpos, y = ypos, rotation = -90,
                    fill = ylabelColor, **textStyle)
        
        # create plot area
        plotArea = self.plotArea = g.Group(transform="translate(%g,%g)" % (dx, dy))
        plotArea.Rect(x = 0, y = 0, width = self.plotWidth, height = self.plotHeight, fill = 'none')
        
        self.yaxis(0, flip = False)
        self.yaxis(self.plotWidth, flip = True, text = False)
        
        if grid:
            self.grid()
        
        # plot bars
        barPAD = 4*self.PAD
        barWidth = (self.plotWidth - 2*(max(1, len(values) - 1))*barPAD) / len(values)
        
        color = itertools.cycle(colors)
        x = barPAD
        for idx, value in enumerate(values):
            barHeight = (value - miny)*self.yscale
            y = self.plotHeight - barHeight
            plotArea.Rect(x = x, y = y, width = barWidth, height = barHeight, fill = color.next())
            
            s = unicode(labels[idx])
            size = self.textSize(s)
            
            xpos = x + .5*barWidth - .5*size.width
            ypos = self.plotHeight + 2*self.PAD + .5*size.height
                
            self.plotArea.EText(self.font, s, x = xpos, y = ypos, 
                                fill = labelColor, **self.textStyle)
            
            
            x += barWidth + barPAD
        
if __name__ == '__main__':
    from svgplotlib.SVG import show
    
    graph = Bar(
        (10,50,100),
        width = 1000, height = 500,
        titleColor = 'blue',
        title = 'Simple bar plot',
        xlabel = 'X axis',
        ylabel = 'Y axis',
        grid = True,
    )
    
    show(graph, graph.width, graph.height)
    