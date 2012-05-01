# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import FLTK as Fl

window = Fl.Window(400,420)

output = Fl.Output(100,20,200,30,"Fl_Output")
output.value('single text line')

moutput = Fl.Multiline_Output(100,60,200,70,"Fl_Multiline_Output")
moutput.value('first text line\nsecond text line')
    
window.end()
window.show()
Fl.run()