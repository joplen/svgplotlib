# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import svgplotlib.FLTK as Fl

def tree_cb(widget, data):
    print 'cb', widget.callback_reason()
    
window = Fl.Double_Window(320,365, 'Tree')

tree = Fl.Tree(5,5,310,355)
tree.showroot(0)
tree.callback(tree_cb)
tree.begin()
tree.add("Flintstones/Fred")
tree.add("Flintstones/Wilma")
tree.add("Flintstones/Pebbles")
tree.add("Simpsons/Homer")
tree.add("Simpsons/Marge")
tree.add("Simpsons/Bart")
tree.add("Simpsons/Lisa")
tree.end()

window.end()
window.show()
Fl.run()
