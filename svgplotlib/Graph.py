#!python -u
# -*- coding: utf-8 -*-
import sys
import datetime

from svgplotlib import Base
from svgplotlib.TEX import isTEX

class Graph(Base):
    """
    Base class for Graphs
    
    By passing the plot limits to the constructor the title,
    scale and labels will be created. This can be used to
    plot multiple graphs on the same graph area.
    
    Example::
        
        # graph with multiple lines
        # first call only sets limits and scales
        graph = Graph(
            (0,20),(0,50),
            width = 1000, height = 500,
            title = 'Simple plot',
            xlabel = 'X axis',
            ylabel = 'Y axis',
            grid = True,
        )
        
        # plot lines
        graph.drawLines((0,10,20),(0,50,25), 'red')
        graph.drawLines((0,10,20),(10,25,50), 'blue', stroke_dasharray="5 5", stroke_width=3)
        
    """
    
    def __init__(self, *args, **kwargs):
        Base.__init__(self, **kwargs)
        
        grid = kwargs.get('grid', False)
        titleColor = kwargs.get('titleColor', 'black')
        titleScale = kwargs.get('titleScale', 1.25)
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
        
        # get data
        if len(args) == 1:
            self.ydata = args[0]
            self.xdata = range(len(self.ydata))
            
        elif len(args) == 2:
            self.xdata, self.ydata = args
        
        else:
            raise ValueError('Expected y, or x, y arguments')
        
        # plot area width and height
        width = kwargs.get('width', 500)
        height = kwargs.get('height', 500)
        assert width > 0 and height > 0, 'width and height must be larger than 0'
        
        aspect = float(width)/height
        assert aspect > .2 and aspect < 5., 'aspect must be between .2 and 5'
        
        self.plotWidth = width
        self.plotHeight = height
        
        maxNumSteps = kwargs.get('maxNumSteps', 5)
        maxMinSteps = kwargs.get('maxMinSteps', 2)
        
        # build xticks
        minx = min(self.xdata)
        maxx = max(self.xdata)
        
        if minx == maxx:
            minx -= 1
            maxx += 1
            
        x1, x2 = self.buildTicks(minx, maxx, maxNumSteps = maxNumSteps, maxMinSteps = maxMinSteps)
        self.xmajorTicks, self.xminorTicks = x1, x2
        
        # build yticks
        miny = min(self.ydata)
        maxy = max(self.ydata)
        
        if miny == maxy:
            miny -= 1
            maxy += 1
            
        y1, y2 = self.buildTicks(miny, maxy, maxNumSteps = maxNumSteps, maxMinSteps = maxMinSteps)
        self.ymajorTicks, self.yminorTicks = y1, y2
        
        # calculate scale
        self.minx = min(min(x1), min(x2 or (sys.maxint,)))
        self.maxx = max(max(x1), max(x2 or (-sys.maxint,)))
        self.miny = min(min(y1), min(y2 or (sys.maxint,)))
        self.maxy = max(max(y1), max(y2 or (-sys.maxint,)))
        
        self.xscale = self.plotWidth/(self.maxx - self.minx)
        self.yscale = self.plotHeight/(self.maxy - self.miny)
        
        # main group
        g = self.Group(**style)
        
        # label size
        delta = self.fontSize + 2*self.PAD
        
        # find height
        h = 0
        dy = .5*self.fontSize
        
        title = unicode(kwargs.get('title', ''))
        titleSize = None
        if title:
            if isTEX(title):
                titleSize = self.TEXSize(title)
            else:
                titleSize = self.textSize(title)
                
            dy += titleScale*(titleSize.height + titleSize.descent) + self.PAD
        
        h += dy                 # Top line space
        h += self.plotHeight    # Plot area
        h += .5*self.fontSize   # yaxis labels
        h += delta              # xaxis labels
        
        xlabel = unicode(kwargs.get('xlabel', ''))
        xlabelSize = None
        if xlabel:
            if isTEX(xlabel):
                xlabelSize = self.TEXSize(xlabel)
            else:
                xlabelSize = self.textSize(xlabel)
            
            h += xlabelSize.height + xlabelSize.descent + self.PAD
        
        # find width
        w = 0
        dx = 0
        
        ylabel = unicode(kwargs.get('ylabel', ''))
        ylabelSize = None
        if ylabel:
            if isTEX(ylabel):
                ylabelSize = self.TEXSize(ylabel)
            else:
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
            
            if isTEX(title):
                g.TEX(title, x = xpos, y = ypos,
                      scale = titleScale, fill = titleColor, **textStyle)
            else:
                g.EText(self.font, title, x = xpos, y = ypos, scale = titleScale,
                        fill = titleColor, **textStyle)
        
        if xlabel:
            xpos = .5*w - .5*xlabelSize.width
            ypos = h - self.PAD
            
            if isTEX(xlabel):
                g.TEX(xlabel, x = xpos, y = ypos,
                      fill = xlabelColor, **textStyle)
            else:
                g.EText(self.font, xlabel, x = xpos, y = ypos,
                        fill = xlabelColor, **textStyle)
        
        if ylabel:
            xpos = ylabelSize.height + ylabelSize.descent + self.PAD
            ypos = dy + .5*self.plotHeight + .5*ylabelSize.width
            
            if isTEX(ylabel):
                g.TEX(ylabel, x = xpos, y = ypos, rotation = -90,
                      fill = ylabelColor, **textStyle)
            else:
                g.EText(self.font, ylabel, x = xpos, y = ypos, rotation = -90,
                        fill = ylabelColor, **textStyle)
        
        # create plot area
        plotArea = self.plotArea = g.Group(transform="translate(%g,%g)" % (dx, dy))
        plotArea.Rect(x = 0, y = 0, width = self.plotWidth, height = self.plotHeight, fill = 'none')
        
        self.xaxis(0, flip = True, text = False)
        self.xaxis(self.plotHeight, flip = False, fmt = kwargs.get('xfmt'))
        
        self.yaxis(0, flip = False, fmt = kwargs.get('yfmt'))
        self.yaxis(self.plotWidth, flip = True, text = False)
        
        if grid:
            self.grid()
    
    def drawLines(self, xdata = None, ydata = None, color = 'black', **kwargs):
        xscale, yscale = self.xscale, self.yscale
        height = self.plotHeight
        
        if xdata is None:
            xdata = self.xdata
        
        if ydata is None:
            ydata = self.ydata
            
        path_data = []
        add = path_data.append
        
        x = xdata[0] - self.minx
        y = ydata[0] - self.miny
        
        add('M %g,%g' % (x*xscale, height - y*yscale))
        
        for x, y in zip(xdata[1:], ydata[1:]):
            x = x - self.minx
            y = y - self.miny
            add('L %g,%g' % (x*xscale, height - y*yscale))
        
        self.plotArea.Path(d = ' '.join(path_data), fill = 'none', stroke = color, **kwargs)
    
    def drawArea(self, xdata = None, ydata = None, fill = 'steelblue',  opacity = .5, **kwargs):
        xscale = self.xscale
        yscale = self.yscale
        plotHeight = self.plotHeight
        
        if xdata is None:
            xdata = self.xdata
        
        if ydata is None:
            ydata = self.ydata
            
        path_data = []
        add = path_data.append
        
        x = self.xdata[0] - self.minx
        y = self.ydata[0] - self.miny
        
        if y > self.miny:
            add('M %g,%g' % (x*xscale, plotHeight - self.miny*yscale))
            add('L %g,%g' % (x*xscale, plotHeight - y*yscale))
        else:
            add('M %g,%g' % (x*xscale, plotHeight - y*yscale))
        
        for x, y in zip(self.xdata[1:], self.ydata[1:]):
            x = x - self.minx
            y = y - self.miny
            add('L %g,%g' % (x*xscale, plotHeight - y*yscale))
        
        if y > self.miny:
            add('L %g,%g' % (x*xscale, plotHeight))
            
        add('Z')
        
        self.plotArea.Path(d = ' '.join(path_data), fill = fill, 
                           opacity = opacity, stroke = 'none', **kwargs)
                           
class LineGraph(Graph):
    """
    Simple line graph
    
    Example::
        graph = LineGraph(
            (0,10,20),(0,50,25),
            width = 1000, height = 500,
            title = 'Simple plot',
            xlabel = 'X axis',
            ylabel = 'Y axis',
            grid = True,
        )
    """
    def __init__(self, *args, **kwargs):
        Graph.__init__(self, *args, **kwargs)
        
        color = kwargs.get('color', 'blue')
        
        # plot graph
        self.drawLines(color = color)
        
class AreaGraph(LineGraph):
    """
    Simple area graph
    
    Example::
        graph = AreaGraph(
            (0,10,20),(0,50,25),
            width = 1000, height = 500,
            fontFamily = 'Arimo',
            fontStyle = 'Italic',
            title = r'Simple plot',
            xlabel = 'X axis',
            ylabel = 'Y axis',
            grid = True,
        )
    """
    def __init__(self, *args, **kwargs):
        LineGraph.__init__(self, *args, **kwargs)
        
        # plot area
        self.drawArea(**kwargs)

class DateGraph(Graph):
    """
    Base class for date plots. For now only month scale
    is supported on the x axis.
    
    By passing the plot limits to the constructor the title,
    scale and labels will be created. This can be used to
    plot multiple graphs on the same graph area.
    """
    def __init__(self, *args, **kwargs):
        xdata, ydata = args
        
        self.startDate = min(xdata)
        self.endDate = end = max(xdata)
        
        xdata = self.scaleDates(xdata)
        
        def fmt(value):
            year = self.startDate.year + int(value / 12)
            month = int(value%12)
            date = datetime.date(year,month + 1,1)
            return date.strftime("%m.%y")
        
        Graph.__init__(self, xdata, ydata, xfmt = fmt, **kwargs)
        
    def scaleDates(self, xdata):
        start = self.startDate
        end = self.endDate
        
        startyear, startmonth = start.year,start.month
        endyear, endmonth = end.year,end.month

        delta = datetime.timedelta(days=1)

        ret = []
        for date in xdata:
            assert date <= end
            
            value = (date.year - startyear)*12
            value += date.month - 1
            
            mstart = datetime.date(date.year, date.month, 1)
            
            if date.month == 12:
                mend = datetime.date(date.year + 1, 1, 1) - delta
            else:
                mend = datetime.date(date.year, date.month + 1, 1) - delta
            
            days = (mend - mstart).days
            value += date.day/float(days + 1)
            
            ret.append(value)
        
        return ret

class DateMonthGraph(DateGraph):
    """
    Date math plot.
    
    Example::
        # plot dates
        xdata = (
            datetime.date(2010,1,5),
            datetime.date(2010,2,15),
            datetime.date(2010,4,15),
            datetime.date(2010,6,15),
        )

        ydata = (
            50.,
            40.5,
            90.,
            50.,
        )
    
        graph = DateMonthGraph(xdata,ydata)
    """
    def __init__(self, *args, **kwargs):
        DateGraph.__init__(self, *args, **kwargs)
        
        # plot graph
        color = kwargs.get('color', 'blue')
        self.drawLines(color = color)
        
if __name__ == '__main__':
    from svgplotlib.SVG import show
    
    '''
    graph = LineGraph(
        (0,10,20),(0,50,25),
        width = 1000, height = 500,
        title = 'Simple plot',
        xlabel = 'X axis',
        ylabel = 'Y axis',
        grid = True,
    )
    '''
    
    '''
    graph = AreaGraph(
        (0,10,20),(0,50,25),
        width = 1000, height = 500,
        fontFamily = 'Arimo',
        fontStyle = 'Italic',
        title = r'Simple plot',
        xlabel = 'X axis',
        ylabel = 'Y axis',
        grid = True,
    )
    '''
    
    '''
    # graph with multiple lines
    # first call only sets limits and scales
    graph = Graph(
        (0,20),(0,50),
        width = 1000, height = 500,
        title = 'Simple plot',
        xlabel = 'X axis',
        ylabel = 'Y axis',
        grid = True,
    )
    
    # plot lines
    graph.drawLines((0,10,20),(0,50,25), 'red')
    graph.drawLines((0,10,20),(10,25,50), 'blue', stroke_dasharray="5 5", stroke_width=3)
    '''
    
    # plot dates
    xdata = (
        datetime.date(2010,1,5),
        datetime.date(2010,2,15),
        datetime.date(2010,4,15),
        datetime.date(2010,6,15),
    )

    ydata = (
        50.,
        40.5,
        90.,
        50.,
    )
    
    graph = DateMonthGraph(xdata,ydata)
    
    show(graph, graph.width, graph.height)