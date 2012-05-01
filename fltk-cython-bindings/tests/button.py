# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import FLTK as Fl

def beepcb(widget, data):
    print 'beep'

def exitcb(widget, data):
    Fl.exit()
    
window = Fl.Window(320,65, 'Buttons')
b1 = Fl.Button(20, 20, 80, 25, "&Beep")
b1.callback(beepcb)
b3 = Fl.Button(220,20, 80, 25, "E&xit")
b3.callback(exitcb)
window.end()
window.show()
Fl.run()