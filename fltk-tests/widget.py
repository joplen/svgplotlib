# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import svgplotlib.FLTK as Fl

class TestWidget(Fl.Widget):
    def __init__(self, X, Y, W, H, L = ''):
        Fl.Widget.__init__(self, X, Y, W, H, L)
        
    def draw(self):
        Fl.color(Fl.BLACK)
        
        Fl.begin_line()
        Fl.vertex(10,10)
        Fl.vertex(380,400)
        Fl.end_line()
        
        Fl.begin_line()
        Fl.vertex(10,400)
        Fl.vertex(380,10)
        Fl.end_line()
    
    def handle(self, event):
        print 'event ', event
        return 0
        
window = Fl.Window(400,420)
widget = TestWidget(10,10,380,400)
window.end()
window.show()
Fl.run()
