# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import FLTK as Fl
    
window = Fl.Window(320,320)
b1 = Fl.Button(10, 10, 300, 300)
image1 = Fl.PNG_Image('sudoku-128.png')
b1.image(image1)
window.end()
window.show()
Fl.run()