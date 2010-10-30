#!python -u
# -*- coding: utf-8 -*-
# Gantt code from Plone : http://svn.plone.org/svn/collective/xm.charting/
import itertools
import calendar
import datetime
from datetime import date
from datetime import timedelta

from svgplotlib import Base

ONEWEEK = timedelta(days=7)
ONEDAY = timedelta(days=1)

# help function to find monday by week number
def weekMonday(year, week):
    startOfYear = datetime.date(year, 1, 1)
    week0 = startOfYear - datetime.timedelta(days=startOfYear.isoweekday())
    mon = week0 + datetime.timedelta(weeks=week) + datetime.timedelta(days=1)
    return mon

class Duration:
    def __init__(self, name, start, end, text = None, color = None):
        self.name = unicode(name)
        self.start = start
        self.end = end
        self.text = unicode(text) if text else None
        self.color = color

class Gantt(Base):
    """
    Gant plot
    
    Example::
        
        items = []
        items.append(Duration('Item 1', date(2009, 1, 4), date(2009, 8, 10), '90%'))
        items.append(Duration('Item 2', date(2009, 3, 11), date(2009, 8, 17), '50%'))
        items.append(Duration('Item 3', date(2009, 4, 18), date(2009, 8, 24), '70%'))
        items.append(Duration('Item 4', date(2009, 5, 25), date(2009, 8, 31), '10%'))
        items.append(Duration('Item 4', date(2009, 5, 25), date(2009, 9, 27), '25%'))
        
        gantt = Gantt(items)
    """
    PAD = 8
    def __init__(self, data, **kwargs):
        # smaller default font
        if not 'fontSize' in kwargs:
            kwargs['fontSize'] = 12
            
        Base.__init__(self, **kwargs)
        
        font = self.font
        fontSize = self.fontSize
        
        style = {
            'stroke'        : kwargs.get('color', 'black'),
            'stroke-width'  : '1',
            'fill'          : kwargs.get('color', 'black'),
        }
        
        dx, dy = self.PAD, self.PAD
        main = self.Group(transform="translate(%d,%d)" % (dx,dy), **style)
        
        # distance between rows
        delta = fontSize + 2*self.PAD
        
        # width & height
        WIDTH = max(1000, kwargs.get('width', 1000)) - 2*self.PAD
        
        # create name column
        def draw_names():
            size = self.textSize(u'Name')
            maxwidth = size.width
            maxheight = 0.
            
            textdata = []
            for duration in data:
                text = unicode(duration.name)
                dur_size = self.textSize(text)
                textdata.append((text,dur_size))
                
                maxwidth = max(dur_size.width, maxwidth)
            
            x, y = Gantt.PAD, .5*delta
            xpos = x
            ypos = y + .5*size.height - .5*size.descent
            main.EText(font, u'Name', x = xpos, y = ypos, stroke='none')
            y += delta
            maxheight += delta
            
            for text, size in textdata:
                ypos = y + .5*size.height - .5*size.descent
                main.EText(font, text, x = x, y = ypos, stroke='none')
                
                y += delta
                maxheight += delta
                
            return maxwidth + 2*Gantt.PAD, maxheight
        
        name_width, HEIGHT = draw_names()
        
        # create vertical lines
        main.Line(x1 = 0, y1 = 0, x2 = 0, y2 = HEIGHT)
        main.Line(x1 = WIDTH, y1 = 0, x2 = WIDTH, y2 = HEIGHT)
        main.Line(x1 = name_width, y1 = 0,
                  x2 = name_width, y2 = HEIGHT)
        
        # create horizontal lines
        y = 0
        for i in range(len(data) + 2):
            main.Line(x1 = 0, y1 = i*delta, x2 = WIDTH, y2 = i*delta)
                  
        
        def draw_duration(x):
            size = self.textSize(u'Duration')
            
            maxwidth = size.width
            textdata = []
            for duration in data:
                days = (duration.end - duration.start).days
                text = u"%d days" % days
                dur_size = self.textSize(text)
                textdata.append((text,dur_size))
                
                maxwidth = max(dur_size.width, maxwidth)
            
            y = .5*delta
            xpos = x + maxwidth + self.PAD - size.width
            ypos = y + .5*size.height - .5*size.descent
            main.EText(font, u'Duration', x = xpos, y = ypos, stroke='none')
            
            y += delta
            for text, size in textdata:
                xpos = x + maxwidth + self.PAD - size.width
                ypos = y + .5*size.height  - .5*size.descent
                main.EText(font, text, x = xpos, y = ypos, stroke='none')
                y += delta
                
            return maxwidth + 2*Gantt.PAD
        
        duration_width = draw_duration(name_width)
        
        # create vertical lines
        main.Line(x1 = name_width + duration_width, y1 = 0,
                  x2 = name_width + duration_width, y2 = HEIGHT)
        
        # find start and end dates
        earliest = data[0].start
        latest = data[0].end
        
        for duration in data:
            if duration.start < earliest:
                earliest = duration.start
                
            if duration.end > latest:
                latest = duration.end
        
        # make sure the first day is the first monday before (or on) the
        # earliest date
        while calendar.weekday(earliest.year, earliest.month,
                               earliest.day) != 0:
            earliest -= ONEDAY
        
        # make sure the last day is the last sunday after (or on) the latest
        # date
        while calendar.weekday(latest.year, latest.month, latest.day) != 6:
            latest += ONEDAY
        
        # how many units is one day?
        if earliest > latest:
            date_delta = earliest - latest
        else:
            date_delta = latest - earliest
        
        day_size = float(WIDTH - (name_width + duration_width)) / date_delta.days
                
        def plot_month(x, start, end):
            y = .25*delta
            year = start.year
            month = start.month
            
            endmonth = end.month
            endyear = end.year
            
            mstart = None
            while year <= endyear:
                if year == endyear and month > endmonth:
                    break
                
                if month > 12:
                    month = 1
                    year += 1
                
                if mstart is None:
                    mstart = start
                else:
                    mstart = datetime.date(year, month, 1)  
                    
                if month == 12:
                    mend = datetime.date(year + 1, 1, 1) - datetime.timedelta(days=1)
                else:
                    mend = datetime.date(year, month + 1, 1) - datetime.timedelta(days=1)
                
                if mend > end:
                    mend = end
                
                rect_width = ((mend - mstart).days) * day_size
                
                s = u"%s %d" % (calendar.month_abbr[month], year)
                size = self.textSize(s)
                
                if size.width > rect_width:
                    s = u"%s %d" % (calendar.month_abbr[month], year)
                    size = self.textSize(s)
                    if size.width > rect_width:
                        s = ""
                
                xpos = x + .5*rect_width - .5*size.width
                ypos = y + .5*size.height - .5*size.descent
                
                if s:
                    main.EText(font, s, x = xpos, y = ypos, stroke='none')
                    
                main.Line(x1 = x, y1 = 0, x2 = x, y2 = .5*delta)
                
                x += rect_width
                month += 1

        plot_month(name_width + duration_width, earliest, latest)
        
        # create horizontal lines
        main.Line(x1 = name_width + duration_width, y1 = .5*delta, x2 = WIDTH, y2 = .5*delta)
                
        def plot_weeks(x, start, end):
            y = .75*delta
            year = start.year
            month = start.month
            week = int(start.strftime("%W"))
            
            endyear = end.year
            endmonth = end.month
            endweek = int(end.strftime("%W"))
            
            wstart = None
            while year <= endyear:
                if x >= WIDTH:
                    break
                
                if wstart is None:
                    wstart = start
                else:
                    wstart = weekMonday(year,week)
                
                wend = wstart + datetime.timedelta(days=6)
                
                rect_width = (wend - wstart).days * day_size
                
                s = u"%d" % week
                size = self.textSize(s)
                
                if size.width > rect_width:
                    s = u""
                
                xpos = x + .5*rect_width - .5*size.width
                ypos = y + .5*size.height - 2.*size.descent
                
                if s and x + size.width <= WIDTH:
                    main.EText(font, s, x = xpos, y = ypos, stroke='none')
                
                main.Line(x1 = x, y1 = .5*delta, x2 = x, y2 = delta)
                
                x += rect_width
                
                # get next week
                next = wstart + datetime.timedelta(days=7)
                week = int(next.strftime("%W"))
                month = int(next.strftime("%m"))
                year = int(next.strftime("%Y"))
        
        plot_weeks(name_width + duration_width, earliest, latest)
        
        def plot_items(x, start, end):
            y = delta
            descent = font.get_descent()/64.
            colors = itertools.cycle(self.COLORS)
            
            for duration in data:
                rect_start = x + (duration.start - start).days * day_size
                
                rect_width = (duration.end - duration.start).days * day_size
                
                color = duration.color or colors.next()
                main.Rect(x = rect_start, y = y, width = rect_width, height = delta, fill = color)
                
                if duration.text:
                    s = unicode(duration.text)
                    size = self.textSize(s)
                    xpos = rect_start + .5*rect_width - .5*size.width
                    ypos = y + .5*size.height + .5*delta
                    main.EText(font, s, x = xpos, y = ypos, stroke='none')
                
                y += delta
                
        plot_items(name_width + duration_width, earliest, latest)
        
        # set total size
        self.set('width', WIDTH + 2*self.PAD)
        self.set('height', HEIGHT + 2*self.PAD)
            
if __name__ == '__main__':
    from svgplotlib.SVG import show
    
    items = []
    items.append(Duration('Item 1', date(2009, 1, 4), date(2009, 8, 10), '90%'))
    items.append(Duration('Item 2', date(2009, 3, 11), date(2009, 8, 17), '50%'))
    items.append(Duration('Item 3', date(2009, 4, 18), date(2009, 8, 24), '70%'))
    items.append(Duration('Item 4', date(2009, 5, 25), date(2009, 8, 31), '10%'))
    items.append(Duration('Item 4', date(2009, 5, 25), date(2009, 9, 27), '25%'))
    
    gantt = Gantt(items)
    #gantt.write(encoding=None)
    #gantt.write(file=open('gantt.svg','wb'))
    show(gantt, gantt.width, gantt.height)