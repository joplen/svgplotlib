# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import FLTK as Fl

window = Fl.Window(400,420)

buffer = Fl.Text_Buffer()
print buffer.length()
buffer.append('testing')
print buffer.length()

widget = Fl.Text_Display(10,10,380,400)
widget.buffer(buffer)

window.end()
window.show()
Fl.run()