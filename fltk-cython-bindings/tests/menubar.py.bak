# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import FLTK as Fl

def cb(widget, data):
    print 'called'
    print widget, data
    
WIDTH  = 700

window = Fl.Window(WIDTH,400)
menubar = Fl.Menu_Bar(0,0,WIDTH,30)
menubar.add("&File",0,None,None,Fl.SUBMENU)
menubar.add("File/Exit1",0,cb,'test1')
menubar.add("File/Exit2",0,cb,'test2')

button = Fl.Menu_Button(10,50,WIDTH/2,30,'Menu Button')
button.add("Exit1",0,cb,'test1')
button.add("Exit2",0,cb,'test2')

choice = Fl.Choice(WIDTH/4,100,WIDTH/2,30,'Choice Button')
first = choice.add("Exit1",0,cb,'test1')
choice.add("Exit2",0,cb,'test2')
choice.value(first)

window.end()
window.show()
Fl.run()