# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import FLTK as Fl

import re

class Date_Input(Fl.Input):
    '''
    Custom date input widget
    '''
    def __init__(self, X, Y, W, H, L = ''):
        Fl.Input.__init__(self, X, Y, W, H, L)
        Fl.Input.callback(self, self.__cb)
        self.when(Fl.WHEN_CHANGED)
        self.tooltip('''Expects iso data format yyyy-mm-dd
with /,- and . as delimiters''')
        self.__user_cb = None
        self.__user_data = None
        
        st = "^(?P<year>\d\d\d\d)(/|-|\.)(?P<month>\d{1,2})(/|-|\.)(?P<day>\d{1,2})$"
        self.date_match = re.compile(st).match
        
    def callback(self, cb, data=None):
        self.__user_cb = cb
        self.__user_data = data
    
    def __cb(self, widget, data):
        print 'cb2 ', widget.value()
        value = widget.value()
        
        def isLeapYear(year):
            if year % 400 == 0: return True
            if year % 100 == 0: return False
            if year % 4 == 0: return True
            return False
        
        def daysInMonth(year, month):
            if isLeapYear(year):
                return (0,31,28,31,30,31,30,31,31,30,31,30,31)[month]
            else:
                return (0,31,29,31,30,31,30,31,31,30,31,30,31)[month]
                
        error = False
        
        match = self.date_match(value)
        if match is None:
            error = True
        else:
            year = int(match.group('year'))
            month = int(match.group('month'))
            day = int(match.group('day'))
            if year < 0 or year > 9999:
                error = True
            
            if month < 1 or month > 12:
                error = True
            
            if day < 1 or day > 31:
                error = True
            
            if day > daysInMonth(year, month):
                error = True
                
        if error:
            print 'error ', self.color()
            self.color(Fl.RED)
            print 'error ', self.color()
            self.redraw()
            return
            
        if self.color() != Fl.BACKGROUND2_COLOR:
            self.color(Fl.BACKGROUND2_COLOR)
            self.redraw()
        
        if self.changed() and not self.__user_cb is None:
            self.__user_cb(self, self.__user_data)
    
def cb(widget, data):
    print 'CB: ' #, widget.label(), widget.value()
    
window = Fl.Window(400,420)
widget = Date_Input(10,10, 100, 30)
widget.callback(cb,'test')
window.end()
window.show()
Fl.run()