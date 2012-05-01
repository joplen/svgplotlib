# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import FLTK as Fl

window = Fl.Window(400,420)

image1 = Fl.PNG_Image('sudoku-128.png')

def cb(self, data, name):
    print 'name = ', name
    return image1
    
widget = Fl.Help_View(10,10,380,400)
widget.value('''<b>Testing</b>
<img src="angry.gif"/>''')
widget.callback(cb, 'testing')
window.end()
window.show()
Fl.run()