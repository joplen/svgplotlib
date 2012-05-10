# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import svgplotlib.FLTK as Fl

def filecb(widget, data):
    native = Fl.Native_File_Chooser()
    native.set_title("Pick a file")
    native.set_filter('''Text\t*.txt
                        C Files\t*.{cxx,h,c}
                        Apps\t*.{app}\n''')
    ret = native.show()
    if ret == -1:
        print 'Error ', native.errmsg()
    elif ret == 1:
        print 'Cancel'
    else:
        print native.filename()
                
def exitcb(widget, data):
    Fl.exit()
    
window = Fl.Window(320,65)
b1 = Fl.Button(20, 20, 80, 25, "&Select file")
b1.callback(filecb)
b3 = Fl.Button(220,20, 80, 25, "E&xit")
b3.callback(exitcb)
window.end()
window.show()
Fl.run()
