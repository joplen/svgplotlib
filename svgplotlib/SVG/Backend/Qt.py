#!/usr/bin/env python -u
import io
import math
import sys

from PyQt4 import QtCore, QtGui, QtSvg

class Viewer(QtGui.QApplication):
    def __init__(self,*args,**kwargs):
        """
        >>> from svgplotlib import SVG
        >>> svg = SVG(width="150", height="150")
        >>> ellipse = svg.Ellipse(cx=80,cy=90, rx=40, ry=20,stroke_width=2, stroke='blue',fill='blue')
        >>> rect    = svg.Rect(fill="red",x=80,y=90, width=20,height=40 )
        >>> viewer  = Viewer(svg)
        """
        super(Viewer,self).__init__(sys.argv)
        self.window = MainWindow(*args,**kwargs)
        self.window.show()
        self.exec_()

class MainWindow(QtGui.QMainWindow):
    def __init__(self, svg, width=None, height=None):
        """
        >>> from svgplotlib import SVG
        >>> svg  = SVG(width="150", height="150")
        >>> grad = svg.defs.linearGradient(id="MyGradient")
        >>> g    = grad.Stop(offset="5%", stop_color="#F60")
        >>> g    = grad.Stop(offset="95%", stop_color="#FF6")
        >>> rect = svg.Rect(fill="url(#MyGradient)", stroke="black", stroke_width=5,
        ...            x=0, y=0,z=-1, width=150, height=150)
        >>> tex  = svg.TEX('$\sum_{i=0}^\infty x_i$')
        >>> app = QtGui.QApplication( sys.argv )
        >>> mw  = MainWindow( svg )
        >>> _   = mw.show()
        >>> _   = app.exec_()
        """
        super(MainWindow, self).__init__()
        self.svg  = svg

        if width is None and hasattr( self.svg, 'width' ):
            width = self.width = self.svg.width
        else:
            self.width  = width
        if height is None and hasattr( self.svg, 'height'):
            height = self.height = self.svg.height
        else:
            self.height = height
        self.setMinimumSize(width , height )
        self.setWindowTitle('show')
        
        self.Actions = {
            'Save' : QtGui.QAction(
                "Save", self, shortcut="Ctrl+S",
                triggered=self.SaveFile
            ),
            'Quit' : QtGui.QAction(
                "Quit", self, shortcut="Ctrl+Q",
                triggered=QtGui.qApp.closeAllWindows
            ),
        }
        
        fileMenu = self.menuBar().addMenu("File")
        fileMenu.addAction(self.Actions['Save'])
        fileMenu.addSeparator()
        fileMenu.addAction(self.Actions['Quit'])
    
        self.widget = SvgWidget(self, width=width, height=height)
        self.setCentralWidget(self.widget)
        
        fh = io.BytesIO()
        self.svg.write(fh)
        self.widget.load(QtCore.QByteArray(fh.getvalue()))
    
    def SaveFile(self): 
        dlg = QtGui.QFileDialog.getSaveFileName
        filename = dlg(self, "Save", '', "svg file ( *.svg ) ;; image file ( *.png )")
        
        if filename:
            filename = unicode(filename)
            
            if filename.endswith('.svg'):
                fh = open(filename, 'wb')
                self.svg.write(fh)
                fh.close()
            else:
                fh = io.BytesIO()
                self.svg.write(fh)
                content = QtCore.QByteArray(fh.getvalue())
                
                image = QtGui.QImage(self.width, self.height, QtGui.QImage.Format_ARGB32_Premultiplied)
                
                painter = QtGui.QPainter(image)
                painter.setViewport(0, 0, self.width, self.height)
                painter.eraseRect(0, 0, self.width, self.height)
                render = QtSvg.QSvgRenderer(content)
                render.render(painter)
                painter.end()
                
                image.save(filename)


class SvgWidget(QtSvg.QSvgWidget):
    def __init__(self, parent, width=0, height=0):
        super(SvgWidget, self).__init__(parent)
        #self.setFixedSize(width, height)
        self.width = width
        self.height = height
        
        # white background
        palette = QtGui.QPalette(self.palette()) 
        palette.setColor(QtGui.QPalette.Window, QtGui.QColor('white')) 
        self.setPalette(palette) 
        self.setAutoFillBackground(True) 
        
    def sizeHint(self):
        return QtCore.QSize(self.width,self.height)

def show(svg, *args,**kwargs):
    '''
    Function to show SVG file with Qt
    '''
    app = Viewer(svg, *args, **kwargs )

if __name__ == '__main__':
    import math
    from svgplotlib import SVG
    svg = SVG(width="150", height="150")
    grad = svg.defs.linearGradient(id="MyGradient")
    grad.Stop(offset="5%", stop_color="#F60")
    grad.Stop(offset="95%", stop_color="#FF6")
    svg.Rect(fill="url(#MyGradient)", stroke="black", stroke_width=5,
             x=0, y=0,z=-1, width=150, height=150)
    svg.TEX('$\sum_{i=0}^\infty x_i$')
    show(svg)
