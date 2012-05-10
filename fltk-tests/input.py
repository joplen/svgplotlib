# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import svgplotlib.FLTK as Fl

def cb(widget, data):
    print 'CB: ', widget.get_label(), widget.get_value()
    
window = Fl.Window(400,420)
input = []
y = 10
input.append(Fl.Input(70,y,300,30,"Normal:"))
y += 35
input.append(Fl.Float_Input(70,y,300,30,"Float:"))
y += 35
input.append(Fl.Int_Input(70,y,300,30,"Int:"))
y += 35
input.append(Fl.Multiline_Input(70,y,300,100,"&Multiline:"))
y += 35

for widget in input:
    widget.callback(cb)
    
window.end()
window.show()
Fl.run()
