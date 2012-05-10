# -*- coding: utf-8 -*-
import sys
sys.path.append('..')
import svgplotlib.FLTK as Fl

import Common.Graphics.GL as gl

class TestWidget(Fl.Gl_Window):
    def __init__(self, X, Y, W, H, L = ''):
        Fl.Gl_Window.__init__(self, X, Y, W, H, L)
        
    def draw(self):
        gl.Disable(gl.LIGHTING)
        gl.ShadeModel(gl.FLAT)
        gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
        gl.LineWidth(2)
        gl.Color4d(1.,0.,0.,1.)
        
        gl.Begin(gl.LINES)
        gl.Vertex3d(-1.,-1.,-1.)
        gl.Vertex3d(1.,1.,1.)
        gl.End()

window = Fl.Window(400,420)
widget = TestWidget(10,10,380,400)
window.end()
window.resizable(widget)
window.show()
widget.show()
widget.redraw()
Fl.run()
